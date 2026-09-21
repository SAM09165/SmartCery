import Foundation

enum RecipeDietCategory: String, Codable {
    case pureVeg = "Strict Pure Veg 🟢"
    case eggitarian = "Eggitarian 🟡"
    case nonVeg = "Non-Vegetarian 🔴"
}

struct PantryRecipeRecommendation: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let summary: String
    let cookTime: String
    let difficulty: String
    let calories: Int
    let proteinGrams: Int
    let dietCategory: RecipeDietCategory
    let usesPantry: [String]
    let missingItems: [String]
    let priorityReason: String
    let iconName: String
    var imageURL: String? = nil

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
    let calories: Int
    let proteinGrams: Int
    let dietCategory: RecipeDietCategory
    let ingredients: [String]
    let optionalIngredients: [String]
    let categoryHints: [String]
    let iconName: String
    var imageURL: String? = nil
}

enum PantryMatcher {
    static func recommendations(for pantry: [PantryItem], dietPreference: DietaryPreference = .pureVeg, limit: Int = 5) -> [PantryRecipeRecommendation] {
        let pantryNames = Set(pantry.map { normalize($0.name) })
        let pantryCategories = Set(pantry.map { normalize($0.category) })

        return recipeTemplates
            .filter { template in
                // Strict Diet Enforcement Rules
                switch dietPreference {
                case .pureVeg, .vegan, .jainVeg:
                    return template.dietCategory == .pureVeg
                case .eggitarian:
                    return template.dietCategory == .pureVeg || template.dietCategory == .eggitarian
                case .nonVeg:
                    return true
                }
            }
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
            calories: template.calories,
            proteinGrams: template.proteinGrams,
            dietCategory: template.dietCategory,
            usesPantry: matchedIngredients + categoryMatches.filter { category in
                !matchedIngredients.contains { normalize($0) == normalize(category) }
            },
            missingItems: missing + template.optionalIngredients.filter { ingredient in
                !pantryNames.contains(normalize(ingredient))
            },
            priorityReason: reason,
            iconName: template.iconName,
            imageURL: template.imageURL
        )
    }

    private static func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static let recipeTemplates: [RecipeTemplate] = [
        RecipeTemplate(
            title: "Spinach Paneer Bowl",
            summary: "Protein-dense cottage cheese sautéed with fresh spinach and mild spices.",
            cookTime: "15 min",
            difficulty: "Easy",
            calories: 420,
            proteinGrams: 28,
            dietCategory: .pureVeg,
            ingredients: ["Paneer", "Spinach", "Tomatoes"],
            optionalIngredients: ["Garlic", "Cumin"],
            categoryHints: ["Dairy", "Veg"],
            iconName: "leaf.fill",
            imageURL: "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=800&q=80"
        ),
        RecipeTemplate(
            title: "Chickpea Coconut Curry",
            summary: "Rich plant-based protein curry with aromatic coconut gravy.",
            cookTime: "20 min",
            difficulty: "Easy",
            calories: 460,
            proteinGrams: 22,
            dietCategory: .pureVeg,
            ingredients: ["Chickpeas", "Rice", "Coconut milk"],
            optionalIngredients: ["Turmeric", "Coriander"],
            categoryHints: ["Staple", "Veg"],
            iconName: "bowl.fill",
            imageURL: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80"
        ),
        RecipeTemplate(
            title: "Dal Tadka & Jeera Rice",
            summary: "Golden yellow lentils tempered with cumin, garlic, and ghee paired with basmati rice.",
            cookTime: "25 min",
            difficulty: "Easy",
            calories: 440,
            proteinGrams: 20,
            dietCategory: .pureVeg,
            ingredients: ["Rice", "Tomatoes", "Onions"],
            optionalIngredients: ["Garlic", "Cumin", "Butter"],
            categoryHints: ["Staple", "Veg"],
            iconName: "flame.fill",
            imageURL: "https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80"
        ),
        RecipeTemplate(
            title: "Tomato Egg Scramble",
            summary: "A fast comfort bowl with soft scrambled eggs, ripe tomatoes, and herbs.",
            cookTime: "12 min",
            difficulty: "Easy",
            calories: 360,
            proteinGrams: 20,
            dietCategory: .eggitarian,
            ingredients: ["Eggs", "Tomatoes", "Onions"],
            optionalIngredients: ["Black pepper", "Butter"],
            categoryHints: ["Protein", "Veg"],
            iconName: "egg.fill",
            imageURL: "https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80"
        ),
        RecipeTemplate(
            title: "Creamy Spinach Pasta",
            summary: "Pantry pasta with greens and a light creamy sauce.",
            cookTime: "22 min",
            difficulty: "Easy",
            calories: 520,
            proteinGrams: 18,
            dietCategory: .pureVeg,
            ingredients: ["Pasta", "Spinach", "Milk", "Cheese"],
            optionalIngredients: ["Garlic", "Black pepper"],
            categoryHints: ["Staple", "Veg", "Dairy"],
            iconName: "fork.knife",
            imageURL: "https://images.unsplash.com/photo-1621996346565-e3d5d6281691?auto=format&fit=crop&w=800&q=80"
        ),
        RecipeTemplate(
            title: "Chicken Potato Skillet",
            summary: "A one-pan dinner using lean chicken breast and sturdy vegetables.",
            cookTime: "30 min",
            difficulty: "Medium",
            calories: 580,
            proteinGrams: 42,
            dietCategory: .nonVeg,
            ingredients: ["Chicken", "Potatoes", "Onions"],
            optionalIngredients: ["Paprika", "Lemon"],
            categoryHints: ["Protein", "Veg"],
            iconName: "frying.pan.fill",
            imageURL: "https://images.unsplash.com/photo-1532550907401-a500c9a57435?auto=format&fit=crop&w=800&q=80"
        ),
        RecipeTemplate(
            title: "Cheese Toast Breakfast",
            summary: "Crisp toast with melted cheese and a quick side.",
            cookTime: "10 min",
            difficulty: "Easy",
            calories: 380,
            proteinGrams: 16,
            dietCategory: .pureVeg,
            ingredients: ["Bread", "Cheese"],
            optionalIngredients: ["Tomatoes", "Chili flakes"],
            categoryHints: ["Bakery", "Dairy"],
            iconName: "sunrise.fill",
            imageURL: "https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80"
        ),
        RecipeTemplate(
            title: "Yogurt Rice Bowl",
            summary: "Cool, simple probiotic rice bowl for light digestive reset.",
            cookTime: "12 min",
            difficulty: "Easy",
            calories: 340,
            proteinGrams: 14,
            dietCategory: .pureVeg,
            ingredients: ["Yogurt", "Rice", "Onions"],
            optionalIngredients: ["Cucumber", "Coriander"],
            categoryHints: ["Dairy", "Staple", "Veg"],
            iconName: "leaf.fill",
            imageURL: "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80"
        )
    ]
}
