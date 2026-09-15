import Foundation
import Combine
import FirebaseFirestore

/// Local-first persistence for core kitchen data. Signed-in users also sync core
/// kitchen data through Firestore while retaining a user-scoped offline cache.
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

    private let offlineStorageKey = "smartcery.app-store.offline.v1"
    private var currentStorageKey = "smartcery.app-store.offline.v1"
    private var currentUserID: String?
    private var pantryListener: ListenerRegistration?
    private var groceryListener: ListenerRegistration?
    private var isCloudSyncActive = false
    private var isApplyingRemoteSnapshot = false

    init() {
        let snapshot = Self.loadSnapshot(forKey: offlineStorageKey)
        pantry = snapshot.pantry
        groceryList = snapshot.groceryList
        profile = snapshot.profile
        hasCompletedOnboarding = snapshot.hasCompletedOnboarding
    }

    func completeOnboarding() { hasCompletedOnboarding = true }
    func setProfile(_ profile: UserProfile) { self.profile = profile }
    func signIn(email: String) { profile = UserProfile(displayName: email.split(separator: "@").first.map(String.init) ?? "Kitchen chef", email: email) }

    func prepareForSignedInUser(uid: String, profile: UserProfile) {
        if currentUserID != uid {
            stopCloudSync()
            currentUserID = uid
            currentStorageKey = Self.storageKey(forUserID: uid)
            applyLocalSnapshot(Self.loadSnapshot(forKey: currentStorageKey))
        }

        self.profile = profile
        startCloudSync()
    }

    func signOut() {
        stopCloudSync()
        currentUserID = nil
        currentStorageKey = offlineStorageKey
        applyLocalSnapshot(Self.loadSnapshot(forKey: offlineStorageKey))
        profile = nil
    }

    func startCloudSync() {
        guard !isCloudSyncActive, currentUserID != nil else { return }
        isCloudSyncActive = true

        pantryListener = FirebaseService.shared.listenToPantryItems { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let items):
                    self?.applyRemotePantry(items)
                case .failure(let error):
                    print("Pantry sync failed: \(error.localizedDescription)")
                }
            }
        }

        groceryListener = FirebaseService.shared.listenToGroceryItems { [weak self] result in
            Task { @MainActor in
                switch result {
                case .success(let items):
                    self?.applyRemoteGroceryList(items)
                case .failure(let error):
                    print("Grocery sync failed: \(error.localizedDescription)")
                }
            }
        }

        uploadLocalCacheToCloud()
    }

    func stopCloudSync() {
        pantryListener?.remove()
        groceryListener?.remove()
        pantryListener = nil
        groceryListener = nil
        isCloudSyncActive = false
    }

    func addPantryItems(_ items: [PantryItem]) {
        var insertedItems: [PantryItem] = []
        for item in items where !pantry.contains(where: { $0.name.caseInsensitiveCompare(item.name) == .orderedSame }) {
            pantry.append(item)
            insertedItems.append(item)
        }
        syncPantryItems(insertedItems)
    }

    func removePantryItem(_ id: UUID) {
        pantry.removeAll { $0.id == id }
        syncPantryDelete(id)
    }

    func extendPantryItem(_ id: UUID, by days: Int = 3) {
        guard let index = pantry.firstIndex(where: { $0.id == id }) else { return }
        let base = pantry[index].expiryDate ?? .now
        pantry[index].expiryDate = Calendar.current.date(byAdding: .day, value: days, to: base)
        syncPantryItems([pantry[index]])
    }

    func addGroceryItem(name: String, quantity: String = "1") {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = GroceryItem(name: trimmed, quantity: quantity)
        groceryList.append(item)
        syncGroceryItems([item])
    }

    func toggleGroceryItem(_ id: UUID) {
        guard let index = groceryList.firstIndex(where: { $0.id == id }) else { return }
        groceryList[index].isChecked.toggle()
        syncGroceryItems([groceryList[index]])
    }

    func removeGroceryItem(_ id: UUID) {
        groceryList.removeAll { $0.id == id }
        syncGroceryDelete(id)
    }

    private func applyLocalSnapshot(_ snapshot: Snapshot) {
        isApplyingRemoteSnapshot = true
        pantry = snapshot.pantry
        groceryList = snapshot.groceryList
        profile = snapshot.profile
        hasCompletedOnboarding = snapshot.hasCompletedOnboarding
        isApplyingRemoteSnapshot = false
    }

    private func applyRemotePantry(_ items: [PantryItem]) {
        guard !isApplyingRemoteSnapshot else { return }
        isApplyingRemoteSnapshot = true
        pantry = items
        isApplyingRemoteSnapshot = false
    }

    private func applyRemoteGroceryList(_ items: [GroceryItem]) {
        guard !isApplyingRemoteSnapshot else { return }
        isApplyingRemoteSnapshot = true
        groceryList = items
        isApplyingRemoteSnapshot = false
    }

    private func uploadLocalCacheToCloud() {
        guard isCloudSyncActive else { return }
        syncPantryItems(pantry)
        syncGroceryItems(groceryList)
    }

    private func syncPantryItems(_ items: [PantryItem]) {
        guard isCloudSyncActive, !isApplyingRemoteSnapshot, !items.isEmpty else { return }
        Task {
            for item in items {
                do {
                    try await FirebaseService.shared.savePantryItem(item)
                } catch {
                    print("Failed to sync pantry item \(item.name): \(error.localizedDescription)")
                }
            }
        }
    }

    private func syncPantryDelete(_ id: UUID) {
        guard isCloudSyncActive, !isApplyingRemoteSnapshot else { return }
        Task {
            do {
                try await FirebaseService.shared.deletePantryItem(id)
            } catch {
                print("Failed to delete pantry item from cloud: \(error.localizedDescription)")
            }
        }
    }

    private func syncGroceryItems(_ items: [GroceryItem]) {
        guard isCloudSyncActive, !isApplyingRemoteSnapshot, !items.isEmpty else { return }
        Task {
            for item in items {
                do {
                    try await FirebaseService.shared.saveGroceryItem(item)
                } catch {
                    print("Failed to sync grocery item \(item.name): \(error.localizedDescription)")
                }
            }
        }
    }

    private func syncGroceryDelete(_ id: UUID) {
        guard isCloudSyncActive, !isApplyingRemoteSnapshot else { return }
        Task {
            do {
                try await FirebaseService.shared.deleteGroceryItem(id)
            } catch {
                print("Failed to delete grocery item from cloud: \(error.localizedDescription)")
            }
        }
    }

    private func save() {
        let snapshot = Snapshot(pantry: pantry, groceryList: groceryList, profile: profile, hasCompletedOnboarding: hasCompletedOnboarding)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: currentStorageKey)
    }

    private static func storageKey(forUserID uid: String) -> String {
        "smartcery.app-store.user.\(uid).v1"
    }

    private static func loadSnapshot(forKey key: String) -> Snapshot {
        guard let data = UserDefaults.standard.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            return Snapshot(pantry: [], groceryList: [], profile: nil, hasCompletedOnboarding: false)
        }
        return snapshot
    }
}
