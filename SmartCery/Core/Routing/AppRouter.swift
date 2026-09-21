import SwiftUI
import Combine

enum AppDestination {
    case loading
    case onboarding
    case auth
    case profileSetup(needsPantrySeed: Bool)
    case pantrySeed
    case dashboard(offline: Bool)
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var destination: AppDestination = .loading

    private let minimumSplashNanoseconds: UInt64 = 1_200_000_000
    private let onboardingKey = "smartcery.onboarding-complete"

    func resolveDestination(authState: SessionManager.AuthState) async {
        let hold = Task {
            try? await Task.sleep(nanoseconds: minimumSplashNanoseconds)
        }

        guard UserDefaults.standard.bool(forKey: onboardingKey) else {
            await hold.value
            destination = .onboarding
            return
        }

        await hold.value
        route(for: authState)
    }

    func route(for authState: SessionManager.AuthState) {
        guard UserDefaults.standard.bool(forKey: onboardingKey) else {
            destination = .onboarding
            return
        }

        // Preserve ongoing profile setup when account creation updates authState
        if case .profileSetup = destination {
            return
        }

        switch authState {
        case .unknown:
            destination = .loading
        case .signedOut:
            destination = .auth
        case .signedIn(let needsPantrySeed):
            destination = needsPantrySeed ? .pantrySeed : .dashboard(offline: false)
        }
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: onboardingKey)
        destination = .auth
    }

    func openProfileSetup(needsPantrySeed: Bool) {
        destination = .profileSetup(needsPantrySeed: needsPantrySeed)
    }

    func completeProfileSetup(needsPantrySeed: Bool) {
        destination = needsPantrySeed ? .pantrySeed : .dashboard(offline: false)
    }

    func completeAuth(needsPantrySeed: Bool) {
        destination = needsPantrySeed ? .pantrySeed : .dashboard(offline: false)
    }

    func openPantrySeed() {
        destination = .pantrySeed
    }

    func completePantrySeed() {
        destination = .dashboard(offline: false)
    }

    func continueOffline() {
        destination = .dashboard(offline: true)
    }
}
