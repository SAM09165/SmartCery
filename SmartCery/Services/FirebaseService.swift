import Foundation

/// Reserved boundary for a future Firebase sync implementation. The app uses
/// `AppStore` as a reliable local-first data source until sync is configured.
final class FirebaseService {
    static let shared = FirebaseService()
    private init() {}
}

struct RecipeDTO: Codable, Identifiable, Hashable {
    var id: UUID
    var title: String
    var instructions: [String]
    var ingredientIDs: [UUID]
    var isFavorite: Bool
    var createdAt: Date
}
