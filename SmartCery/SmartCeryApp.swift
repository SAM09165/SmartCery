import SwiftUI
import FirebaseCore

@main
struct SmartCeryApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var store = AppStore()
    @StateObject private var sessionManager = SessionManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(store)
                .environmentObject(sessionManager)
                .task {
                    NotificationService.shared.requestPermission()
                }
        }
    }
}
