import Foundation

struct PantryRecipeRecommendation: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let summary: String
    let cookTime: String
    let difficulty: String
    let usesPantry: [String]
    let missingItems: [String]
    let priorityReason: String
    let iconName: String

    var matchScore: Int {
        let total = max(usesPantry.count + missingItems.count, 1)
        return Int((Double(usesPantry.count) / Double(total) * 100).rounded())
    }
}

struct RecipeTemplate {
    let title: String
    let summary: String
    let cookTime: String
    let difficulty: String
    let ingredients: [String]
    let optionalIngredients: [String]
    let categoryHints: [String]
    let iconName: String
}

enum PantryMatcher {
    static func recommendations(for pantry: [PantryItem], limit: Int = 5) -> [PantryRecipeRecommendation] {
        let pantryNames = Set(pantry.map { normalize($0.name) })
        let pantryCategories = Set(pantry.map { normalize($0.category) })

        return recipeTemplates
            .map { template in
                recommendation(for: template, pantryNames: pantryNames, pantryCategories: pantryCategories, pantry: pantry)
            }
            .sorted { first, second in
                if first.matchScore == second.matchScore {
                    return first.missingItems.count < second.missingItems.count
                }
                return first.matchScore > second.matchScore
            }
            .prefix(limit)
            .map { $0 }
    }

    private static func recommendation(
        for template: RecipeTemplate,
        pantryNames: Set<String>,
        pantryCategories: Set<String>,
        pantry: [PantryItem]
    ) -> PantryRecipeRecommendation {
        let matchedIngredients = template.ingredients.filter { ingredient in
            pantryNames.contains(normalize(ingredient))
        }

        let categoryMatches = template.categoryHints.filter { pantryCategories.contains(normalize($0)) }
        let missing = template.ingredients.filter { ingredient in
            !pantryNames.contains(normalize(ingredient))
        }

        let reason: String
        if let urgentItem = pantry.first(where: { item in
            if case .fresh = Expirychecker.status(for: item.expiryDate) { return false }
            return matchedIngredients.contains { normalize($0) == normalize(item.name) }
        }) {
            reason = "Uses \(urgentItem.name) before it needs attention."
        } else if !categoryMatches.isEmpty {
            reason = "Fits your \(categoryMatches[0].lowercased()) stock."
        } else if matchedIngredients.isEmpty {
            reason = "A good starter meal for a fuller pantry."
        } else {
            reason = "Uses \(matchedIngredients.prefix(2).joined(separator: " and "))."
        }

        return PantryRecipeRecommendation(
            title: template.title,
            summary: template.summary,
            cookTime: template.cookTime,
            difficulty: template.difficulty,
            usesPantry: matchedIngredients + categoryMatches.filter { category in
                !matchedIngredients.contains { normalize($0) == normalize(category) }
            },
            missingItems: missing + template.optionalIngredients.filter { ingredient in
                !pantryNames.contains(normalize(ingredient))
            },
            priorityReason: reason,
            iconName: template.iconName
        )
    }

    private static func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static let recipeTemplates: [RecipeTemplate] = [
        RecipeTemplate(
            title: "Tomato Egg Rice Bowl",
            summary: "A fast comfort bowl with soft eggs, tomatoes, and rice.",
            cookTime: "18 min",
            difficulty: "Easy",
            ingredients: ["Eggs", "Tomatoes", "Rice"],
            optionalIngredients: ["Soy sauce", "Spring onion"],
            categoryHints: ["Protein", "Veg", "Staple"],
            iconName: "bowl.fill"
        ),
        RecipeTemplate(
            title: "Creamy Spinach Pasta",
            summary: "Pantry pasta with greens and a light creamy sauce.",
            cookTime: "22 min",
            difficulty: "Easy",
            ingredients: ["Pasta", "Spinach", "Milk", "Cheese"],
            optionalIngredients: ["Garlic", "Black pepper"],
            categoryHints: ["Staple", "Veg", "Dairy"],
            iconName: "fork.knife"
        ),
        RecipeTemplate(
            title: "Chicken Potato Skillet",
            summary: "A one-pan dinner using protein and sturdy vegetables.",
            cookTime: "30 min",
            difficulty: "Medium",
            ingredients: ["Chicken", "Potatoes", "Onions"],
            optionalIngredients: ["Paprika", "Lemon"],
            categoryHints: ["Protein", "Veg"],
            iconName: "frying.pan.fill"
        ),
        RecipeTemplate(
            title: "Cheese Toast Breakfast",
            summary: "Crisp toast with melted cheese and a quick side.",
            cookTime: "10 min",
            difficulty: "Easy",
            ingredients: ["Bread", "Cheese"],
            optionalIngredients: ["Tomatoes", "Chili flakes"],
            categoryHints: ["Bakery", "Dairy"],
            iconName: "sunrise.fill"
        ),
        RecipeTemplate(
            title: "Yogurt Rice Bowl",
            summary: "Cool, simple rice bowl for days when cooking should stay light.",
            cookTime: "12 min",
            difficulty: "Easy",
            ingredients: ["Yogurt", "Rice", "Onions"],
            optionalIngredients: ["Cucumber", "Coriander"],
            categoryHints: ["Dairy", "Staple", "Veg"],
            iconName: "leaf.fill"
        ),
        RecipeTemplate(
            title: "Tomato Bread Soup",
            summary: "A low-waste soup that turns tomatoes and bread into dinner.",
            cookTime: "25 min",
            difficulty: "Easy",
            ingredients: ["Tomatoes", "Bread", "Onions"],
            optionalIngredients: ["Garlic", "Basil"],
            categoryHints: ["Veg", "Bakery"],
            iconName: "takeoutbag.and.cup.and.straw.fill"
        )
    ]
}
