import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    enum Mode: Equatable { case signIn, createAccount }

    @Published var email = ""
    @Published var password = ""
    @Published private(set) var mode: Mode = .signIn
    @Published private(set) var statusMessage = "Use any valid email and a six-character password to get started. Your kitchen data stays on this device."

    var title: String { mode == .signIn ? "Welcome back" : "Create your kitchen" }
    var subtitle: String { mode == .signIn ? "Pick up where your pantry left off." : "Start tracking food, meals, and groceries in one place." }
    var primaryButtonTitle: String { mode == .signIn ? "Continue" : "Create account" }
    var toggleTitle: String { mode == .signIn ? "New here? Create an account" : "Already have an account? Sign in" }

    func toggleMode() {
        mode = mode == .signIn ? .createAccount : .signIn
        statusMessage = mode == .signIn ? "Welcome back. Your saved kitchen is ready." : "Create a local profile to keep this kitchen personal."
    }

    func submit() -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            statusMessage = "Enter a valid email address to continue."
            return false
        }
        guard password.count >= 6 else {
            statusMessage = "Use a password with at least six characters."
            return false
        }
        email = trimmedEmail
        statusMessage = "All set — your kitchen is ready."
        return true
    }
}
