import Foundation
import Combine

@MainActor
final class ChefZestViewModel: ObservableObject {
    @Published private(set) var recommendations: [PantryRecipeRecommendation] = []
    @Published private(set) var grocerySuggestions: [String] = []

    var headline: String {
        if recommendations.isEmpty {
            return "Add pantry items to unlock meal ideas."
        }
        return "Chef Zest found \(recommendations.count) meals from your pantry."
    }

    var subheadline: String {
        if recommendations.isEmpty {
            return "Start with basics like rice, eggs, milk, tomatoes, bread, or spinach."
        }
        return "Suggestions prioritize food you already own and items that need attention soon."
    }

    func refresh(pantry: [PantryItem], groceryList: [GroceryItem]) {
        recommendations = PantryMatcher.recommendations(for: pantry)
        grocerySuggestions = GroceryListGenerator.missingIngredients(
            from: recommendations,
            existingGroceryItems: groceryList
        )
    }
}
