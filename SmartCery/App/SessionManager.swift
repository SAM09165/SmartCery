import Foundation
import Combine
import FirebaseAuth
import FirebaseCore

@MainActor
final class SessionManager: ObservableObject {
    enum AuthState: Equatable {
        case unknown
        case signedOut
        case signedIn(needsProfileSetup: Bool, needsPantrySeed: Bool)
    }

    @Published private(set) var authState: AuthState = .unknown
    @Published private(set) var profile: UserProfile?
    @Published private(set) var currentUserID: String?

    private var handle: AuthStateDidChangeListenerHandle?
    private var hasStarted = false

    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        ensureFirebaseConfigured()

        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }

            Task { @MainActor in
                guard let user else {
                    self.currentUserID = nil
                    self.profile = nil
                    self.authState = .signedOut
                    return
                }

                do {
                    let record = try await FirebaseService.shared.ensureUserRecord(for: user)
                    self.currentUserID = record.uid
                    self.profile = record.profile
                    self.authState = .signedIn(
                        needsProfileSetup: !record.hasCompletedProfile,
                        needsPantrySeed: !record.hasCompletedPantrySeed
                    )
                } catch {
                    self.currentUserID = user.uid
                    self.profile = UserProfile(displayName: user.email ?? "Kitchen chef", email: user.email ?? "")
                    self.authState = .signedIn(needsProfileSetup: false, needsPantrySeed: false)
                    print("Failed to load Firebase user profile: \(error.localizedDescription)")
                }
            }
        }
    }

    func waitForResolvedAuthState(timeoutNanoseconds: UInt64 = 5_000_000_000) async -> AuthState {
        start()
        let pollNanoseconds: UInt64 = 100_000_000
        var elapsedNanoseconds: UInt64 = 0

        while authState == .unknown && elapsedNanoseconds < timeoutNanoseconds {
            try? await Task.sleep(nanoseconds: pollNanoseconds)
            elapsedNanoseconds += pollNanoseconds
        }

        return authState
    }

    func applySignedInRecord(_ record: FirebaseUserRecord) {
        currentUserID = record.uid
        profile = record.profile
        authState = .signedIn(
            needsProfileSetup: !record.hasCompletedProfile,
            needsPantrySeed: !record.hasCompletedPantrySeed
        )
    }

    func markProfileCompleted(with updatedProfile: UserProfile) {
        self.profile = updatedProfile
        if case .signedIn(_, let needsPantrySeed) = authState {
            self.authState = .signedIn(needsProfileSetup: false, needsPantrySeed: needsPantrySeed)
        } else {
            self.authState = .signedIn(needsProfileSetup: false, needsPantrySeed: false)
        }
    }

    func markPantrySeedCompleted() {
        if case .signedIn(let needsProfileSetup, _) = authState {
            self.authState = .signedIn(needsProfileSetup: needsProfileSetup, needsPantrySeed: false)
        } else {
            self.authState = .signedIn(needsProfileSetup: false, needsPantrySeed: false)
        }
    }

    func signOut() {
        ensureFirebaseConfigured()
        do {
            try Auth.auth().signOut()
            currentUserID = nil
            profile = nil
            authState = .signedOut
        } catch {
            print("Sign out failed: \(error.localizedDescription)")
        }
    }

    deinit {
        ensureFirebaseConfigured()
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }
}
