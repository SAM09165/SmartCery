import Foundation
import Combine

/// Local-first persistence for core kitchen data. A cloud sync layer can be
/// added later without making the app unusable offline.
@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var pantry: [PantryItem] { didSet { save() } }
    @Published private(set) var groceryList: [GroceryItem] { didSet { save() } }
    @Published private(set) var profile: UserProfile? { didSet { save() } }
    @Published private(set) var hasCompletedOnboarding: Bool { didSet { save() } }

    private struct Snapshot: Codable {
        var pantry: [PantryItem]
        var groceryList: [GroceryItem]
        var profile: UserProfile?
        var hasCompletedOnboarding: Bool
    }

    private let storageKey = "smartcery.app-store.v1"

    init() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            pantry = []
            groceryList = []
            profile = nil
            hasCompletedOnboarding = false
            return
        }
        pantry = snapshot.pantry
        groceryList = snapshot.groceryList
        profile = snapshot.profile
        hasCompletedOnboarding = snapshot.hasCompletedOnboarding
    }

    func completeOnboarding() { hasCompletedOnboarding = true }
    func signIn(email: String) { profile = UserProfile(displayName: email.split(separator: "@").first.map(String.init) ?? "Kitchen chef", email: email) }
    func signOut() { profile = nil }

    func addPantryItems(_ items: [PantryItem]) {
        for item in items where !pantry.contains(where: { $0.name.caseInsensitiveCompare(item.name) == .orderedSame }) {
            pantry.append(item)
        }
    }
    func removePantryItem(_ id: UUID) { pantry.removeAll { $0.id == id } }
    func extendPantryItem(_ id: UUID, by days: Int = 3) {
        guard let index = pantry.firstIndex(where: { $0.id == id }) else { return }
        let base = pantry[index].expiryDate ?? .now
        pantry[index].expiryDate = Calendar.current.date(byAdding: .day, value: days, to: base)
    }
    func addGroceryItem(name: String, quantity: String = "1") {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        groceryList.append(GroceryItem(name: trimmed, quantity: quantity))
    }
    func toggleGroceryItem(_ id: UUID) {
        guard let index = groceryList.firstIndex(where: { $0.id == id }) else { return }
        groceryList[index].isChecked.toggle()
    }
    func removeGroceryItem(_ id: UUID) { groceryList.removeAll { $0.id == id } }

    private func save() {
        let snapshot = Snapshot(pantry: pantry, groceryList: groceryList, profile: profile, hasCompletedOnboarding: hasCompletedOnboarding)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
