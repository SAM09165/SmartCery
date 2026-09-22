import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

func ensureFirebaseConfigured() {
    if FirebaseApp.app() == nil {
        FirebaseApp.configure()
    }
}

struct FirebaseUserRecord: Equatable {
    let uid: String
    let email: String
    let displayName: String
    let hasCompletedPantrySeed: Bool
    let hasCompletedProfile: Bool
    let profile: UserProfile
}

final class FirebaseService {
    static let shared = FirebaseService()

    private var database: Firestore {
        ensureFirebaseConfigured()
        return Firestore.firestore()
    }
    private let usersCollection = "users"
    private let pantryCollection = "pantryItems"
    private let groceryCollection = "groceryItems"

    private init() {
        ensureFirebaseConfigured()
    }

    func signIn(email: String, password: String) async throws -> FirebaseUserRecord {
        ensureFirebaseConfigured()
        let result = try await signInUser(email: email, password: password)
        return await ensureUserRecord(for: result.user)
    }

    func createAccount(email: String, password: String) async throws -> FirebaseUserRecord {
        ensureFirebaseConfigured()
        let result = try await createUser(email: email, password: password)
        return await ensureUserRecord(for: result.user)
    }

    func ensureUserRecord(for user: User) async -> FirebaseUserRecord {
        ensureFirebaseConfigured()
        let reference = userReference(for: user.uid)
        let fallbackEmail = user.email ?? ""
        let fallbackDisplayName = displayName(from: fallbackEmail)

        do {
            let snapshot = try await getDocument(reference)
            if let data = snapshot.data() {
                let email = data["email"] as? String ?? fallbackEmail
                let displayName = data["displayName"] as? String ?? fallbackDisplayName
                let hasCompletedPantrySeed = data["hasCompletedPantrySeed"] as? Bool ?? false
                let hasCompletedProfile = data["hasCompletedProfile"] as? Bool ?? false

                let age = data["age"] as? Int ?? 26
                let gender = data["gender"] as? String ?? "Male"
                let heightCm = data["heightCm"] as? Double ?? 175.0
                let weightKg = data["weightKg"] as? Double ?? 70.0
                let dietPrefString = data["dietPreference"] as? String ?? "Strict Pure Veg"
                let dietPreference = DietaryPreference(rawValue: dietPrefString) ?? .pureVeg
                let workoutString = data["workoutFrequency"] as? String ?? "Moderate (3-4 days/week)"
                let workoutFrequency = WorkoutFrequency(rawValue: workoutString) ?? .moderate
                let goalString = data["fitnessGoal"] as? String ?? "Fat Loss / Weight Loss"
                let fitnessGoal = FitnessGoal(rawValue: goalString) ?? .fatLoss

                let profile = UserProfile(
                    displayName: displayName,
                    email: email,
                    age: age,
                    gender: gender,
                    heightCm: heightCm,
                    weightKg: weightKg,
                    dietPreference: dietPreference,
                    workoutFrequency: workoutFrequency,
                    fitnessGoal: fitnessGoal,
                    profileCompleted: hasCompletedProfile
                )

                return FirebaseUserRecord(
                    uid: user.uid,
                    email: email,
                    displayName: displayName,
                    hasCompletedPantrySeed: hasCompletedPantrySeed,
                    hasCompletedProfile: hasCompletedProfile,
                    profile: profile
                )
            }
        } catch {
            print("FirebaseService.ensureUserRecord: Could not read Firestore document: \(error.localizedDescription)")
        }

        let defaultProfile = UserProfile(
            displayName: fallbackDisplayName,
            email: fallbackEmail,
            profileCompleted: false
        )
        let record = FirebaseUserRecord(
            uid: user.uid,
            email: fallbackEmail,
            displayName: fallbackDisplayName,
            hasCompletedPantrySeed: false,
            hasCompletedProfile: false,
            profile: defaultProfile
        )
        do {
            try await setData([
                "uid": record.uid,
                "email": record.email,
                "displayName": record.displayName,
                "hasCompletedPantrySeed": false,
                "hasCompletedProfile": false,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ], on: reference, merge: true)
        } catch {
            print("FirebaseService.ensureUserRecord: Could not save Firestore document: \(error.localizedDescription)")
        }
        return record
    }

    func saveUserProfile(_ profile: UserProfile) async throws {
        ensureFirebaseConfigured()
        guard let user = Auth.auth().currentUser else { return }
        try await setData([
            "displayName": profile.displayName,
            "age": profile.age,
            "gender": profile.gender,
            "heightCm": profile.heightCm,
            "weightKg": profile.weightKg,
            "dietPreference": profile.dietPreference.rawValue,
            "workoutFrequency": profile.workoutFrequency.rawValue,
            "fitnessGoal": profile.fitnessGoal.rawValue,
            "hasCompletedProfile": true,
            "updatedAt": FieldValue.serverTimestamp()
        ], on: userReference(for: user.uid), merge: true)
    }

    func markPantrySeedCompleted() async throws {
        ensureFirebaseConfigured()
        guard let user = Auth.auth().currentUser else { return }
        try await setData([
            "hasCompletedPantrySeed": true,
            "updatedAt": FieldValue.serverTimestamp()
        ], on: userReference(for: user.uid), merge: true)
    }

    func listenToPantryItems(_ onChange: @escaping (Result<[PantryItem], Error>) -> Void) -> ListenerRegistration? {
        ensureFirebaseConfigured()
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return pantryReference(for: uid)
            .order(by: "name")
            .addSnapshotListener { snapshot, error in
                if let error {
                    onChange(.failure(error))
                    return
                }

                let items = snapshot?.documents.compactMap { PantryItem(documentID: $0.documentID, data: $0.data()) } ?? []
                onChange(.success(items))
            }
    }

    func listenToGroceryItems(_ onChange: @escaping (Result<[GroceryItem], Error>) -> Void) -> ListenerRegistration? {
        ensureFirebaseConfigured()
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return groceryReference(for: uid)
            .order(by: "createdAt")
            .addSnapshotListener { snapshot, error in
                if let error {
                    onChange(.failure(error))
                    return
                }

                let items = snapshot?.documents.compactMap { GroceryItem(documentID: $0.documentID, data: $0.data()) } ?? []
                onChange(.success(items))
            }
    }

    func savePantryItem(_ item: PantryItem) async throws {
        ensureFirebaseConfigured()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await setData(item.firestoreData, on: pantryReference(for: uid).document(item.id.uuidString), merge: true)
    }

    func deletePantryItem(_ id: UUID) async throws {
        ensureFirebaseConfigured()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await deleteDocument(pantryReference(for: uid).document(id.uuidString))
    }

    func saveGroceryItem(_ item: GroceryItem) async throws {
        ensureFirebaseConfigured()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await setData(item.firestoreData, on: groceryReference(for: uid).document(item.id.uuidString), merge: true)
    }

    func deleteGroceryItem(_ id: UUID) async throws {
        ensureFirebaseConfigured()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await deleteDocument(groceryReference(for: uid).document(id.uuidString))
    }

    private func signInUser(email: String, password: String) async throws -> AuthDataResult {
        ensureFirebaseConfigured()
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthDataResult, Error>) in
            func attempt(_ remainingRetries: Int) {
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error = error as NSError? {
                        if let code = AuthErrorCode(rawValue: error.code), (code == .internalError || code == .networkError), remainingRetries > 0 {
                            print("FirebaseService.signInUser retrying due to transient error: code=\(error.code) userInfo=\(error.userInfo)")
                            DispatchQueue.global().asyncAfter(deadline: .now() + 0.6) {
                                attempt(remainingRetries - 1)
                            }
                            return
                        }
                        print("FirebaseService.signInUser failed: code=\(error.code) domain=\(error.domain) userInfo=\(error.userInfo)")
                        continuation.resume(throwing: error)
                    } else if let result {
                        continuation.resume(returning: result)
                    } else {
                        continuation.resume(throwing: FirebaseServiceError.missingAuthResult)
                    }
                }
            }
            attempt(1)
        }
    }

    private func createUser(email: String, password: String) async throws -> AuthDataResult {
        ensureFirebaseConfigured()
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthDataResult, Error>) in
            func attempt(_ remainingRetries: Int) {
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error as NSError? {
                        if let code = AuthErrorCode(rawValue: error.code), (code == .internalError || code == .networkError), remainingRetries > 0 {
                            print("FirebaseService.createUser retrying due to transient error: code=\(error.code) userInfo=\(error.userInfo)")
                            DispatchQueue.global().asyncAfter(deadline: .now() + 0.6) {
                                attempt(remainingRetries - 1)
                            }
                            return
                        }
                        print("FirebaseService.createUser failed: code=\(error.code) domain=\(error.domain) userInfo=\(error.userInfo)")
                        continuation.resume(throwing: error)
                    } else if let result {
                        continuation.resume(returning: result)
                    } else {
                        continuation.resume(throwing: FirebaseServiceError.missingAuthResult)
                    }
                }
            }
            attempt(1)
        }
    }

    private func userReference(for uid: String) -> DocumentReference {
        database.collection(usersCollection).document(uid)
    }

    private func pantryReference(for uid: String) -> CollectionReference {
        userReference(for: uid).collection(pantryCollection)
    }

    private func groceryReference(for uid: String) -> CollectionReference {
        userReference(for: uid).collection(groceryCollection)
    }

    private func getDocument(_ reference: DocumentReference) async throws -> DocumentSnapshot {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<DocumentSnapshot, Error>) in
            reference.getDocument { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let snapshot {
                    continuation.resume(returning: snapshot)
                } else {
                    continuation.resume(throwing: FirebaseServiceError.missingDocumentSnapshot)
                }
            }
        }
    }

    private func setData(_ data: [String: Any], on reference: DocumentReference, merge: Bool) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            reference.setData(data, merge: merge) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func deleteDocument(_ reference: DocumentReference) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            reference.delete { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func displayName(from email: String) -> String {
        let localPart = email.split(separator: "@").first.map(String.init) ?? "Kitchen chef"
        return localPart.replacingOccurrences(of: ".", with: " ").capitalized
    }
}

enum FirebaseServiceError: LocalizedError {
    case missingAuthResult
    case missingDocumentSnapshot

    var errorDescription: String? {
        switch self {
        case .missingAuthResult:
            return "Firebase did not return an authenticated user."
        case .missingDocumentSnapshot:
            return "Firebase did not return a user document."
        }
    }
}

private extension PantryItem {
    init?(documentID: String, data: [String: Any]) {
        guard let id = UUID(uuidString: documentID),
              let name = data["name"] as? String,
              let category = data["category"] as? String,
              let quantity = data["quantity"] as? String else {
            return nil
        }

        let iconName = data["iconName"] as? String ?? "cabinet.fill"
        let expiryDate = (data["expiryDate"] as? Timestamp)?.dateValue()

        self.init(
            id: id,
            name: name,
            category: category,
            quantity: quantity,
            expiryDate: expiryDate,
            iconName: iconName
        )
    }

    var firestoreData: [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "name": name,
            "category": category,
            "quantity": quantity,
            "iconName": iconName,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        if let expiryDate {
            dict["expiryDate"] = Timestamp(date: expiryDate)
        }
        return dict
    }
}

private extension GroceryItem {
    init?(documentID: String, data: [String: Any]) {
        guard let id = UUID(uuidString: documentID),
              let name = data["name"] as? String,
              let quantity = data["quantity"] as? String else {
            return nil
        }

        let isChecked = data["isChecked"] as? Bool ?? false
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()

        self.init(
            id: id,
            name: name,
            quantity: quantity,
            isChecked: isChecked,
            createdAt: createdAt
        )
    }

    var firestoreData: [String: Any] {
        [
            "id": id.uuidString,
            "name": name,
            "quantity": quantity,
            "isChecked": isChecked,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": FieldValue.serverTimestamp()
        ]
    }
}
