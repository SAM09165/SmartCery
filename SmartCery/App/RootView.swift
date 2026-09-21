import SwiftUI

struct RootView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var sessionManager: SessionManager

    var body: some View {
        Group {
            switch router.destination {
            case .loading:
                SplashView()
            case .onboarding:
                OnboardingView()
            case .auth:
                AuthView()
            case .profileSetup(let needsPantrySeed):
                ProfileSetupView(needsPantrySeed: needsPantrySeed)
            case .pantrySeed:
                PantrySeedView(mode: .firstTime)
            case .dashboard:
                MainTabView()
            }
        }
        .onChange(of: sessionManager.profile) { _, _ in
            prepareStoreForCurrentSession()
        }
        .onChange(of: sessionManager.authState) { _, authState in
            handleAuthState(authState)
        }
        .task {
            await sessionManager.waitForResolvedAuthState()
        }
    }

    private func handleAuthState(_ authState: SessionManager.AuthState) {
        switch authState {
        case .unknown:
            break
        case .signedOut:
            store.stopCloudSync()
        case .signedIn:
            prepareStoreForCurrentSession()
        }

        guard !isShowingSplash else { return }

        if case .profileSetup = router.destination {
            return
        }

        router.route(for: authState)
    }

    private func prepareStoreForCurrentSession() {
        guard let uid = sessionManager.currentUserID, let profile = sessionManager.profile else { return }
        store.prepareForSignedInUser(uid: uid, profile: profile)
    }

    private var isShowingSplash: Bool {
        if case .loading = router.destination {
            return true
        }
        return false
    }
}

#Preview {
    RootView()
        .environmentObject(AppRouter())
        .environmentObject(AppStore())
        .environmentObject(SessionManager())
}
