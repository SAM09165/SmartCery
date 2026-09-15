import Foundation

enum GroceryListGenerator {
    static func missingIngredients(
        from recommendations: [PantryRecipeRecommendation],
        existingGroceryItems: [GroceryItem],
        limit: Int = 8
    ) -> [String] {
        let existing = Set(existingGroceryItems.map { normalize($0.name) })
        var seen = Set<String>()
        var suggestions: [String] = []

        for item in recommendations.flatMap(\.missingItems) {
            let normalized = normalize(item)
            guard !normalized.isEmpty, !existing.contains(normalized), !seen.contains(normalized) else { continue }
            seen.insert(normalized)
            suggestions.append(item)

            if suggestions.count == limit {
                break
            }
        }

        return suggestions
    }

    private static func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
