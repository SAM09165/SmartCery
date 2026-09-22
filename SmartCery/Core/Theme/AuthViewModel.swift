import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    enum Mode: Equatable { case signIn, createAccount }
    enum AuthInputType: Equatable { case email, phone }

    @Published var email = ""
    @Published var password = ""
    @Published var phoneNumber = ""
    @Published var selectedCountryCode = "IN +91"
    @Published var inputType: AuthInputType = .email

    @Published private(set) var mode: Mode = .signIn
    @Published private(set) var statusMessage = "Log in or sign up to save your pantry & diet goals."
    @Published private(set) var isSubmitting = false

    let countryCodes = ["IN +91", "SG +65", "US +1", "UK +44", "AE +971"]

    var title: String {
        "India’s #1 AI Diet & Zero-Waste Kitchen Assistant"
    }

    var subtitle: String {
        mode == .signIn ? "Log in to sync your SmartCery kitchen." : "Create an account for personalized diet plans."
    }

    var primaryButtonTitle: String {
        mode == .signIn ? "Continue" : "Create account"
    }

    var toggleTitle: String {
        mode == .signIn ? "New here? Create an account" : "Already have an account? Log in"
    }

    func toggleMode() {
        mode = mode == .signIn ? .createAccount : .signIn
        statusMessage = mode == .signIn ? "Enter your email & password to log in." : "Create an account with email and password."
    }

    func submit() async -> FirebaseUserRecord? {
        if inputType == .phone {
            let digits = phoneNumber.filter(\.isNumber)
            guard digits.count >= 8 else {
                statusMessage = "Please enter a valid mobile number."
                return nil
            }
            // Extract the dial code numeric digits (e.g., "+91" -> "91")
            let dialCode = selectedCountryCode.filter(\.isNumber)
            // For phone authentication fallback to user email alias for Firebase email auth
            email = "user_\(dialCode)_\(digits)@smartcery.app"
            if password.isEmpty { password = "SmartCeryPassword#1" }
        }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            statusMessage = "Enter a valid email address to continue."
            return nil
        }
        guard password.count >= 6 else {
            statusMessage = "Use a password with at least 6 characters."
            return nil
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            email = trimmedEmail
            let record: FirebaseUserRecord
            switch mode {
            case .signIn:
                record = try await FirebaseService.shared.signIn(email: trimmedEmail, password: password)
            case .createAccount:
                record = try await FirebaseService.shared.createAccount(email: trimmedEmail, password: password)
            }
            statusMessage = "All set! Your SmartCery account is ready."
            return record
        } catch {
            let ns = error as NSError
            print("Auth submit failed: domain=\(ns.domain) code=\(ns.code) userInfo=\(ns.userInfo)")
            statusMessage = readableMessage(for: error)
            return nil
        }
    }

    private func readableMessage(for error: Error) -> String {
        let message = mapAuthError(error)
        if message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Authentication failed. Please try again."
        }
        return message
    }

    private func mapAuthError(_ error: Error) -> String {
        let ns = error as NSError
        let domain = ns.domain
        let code = ns.code

        if domain == "FIRAuthInternalErrorDomain" {
            switch code {
            case 3:
                return "Email/Password sign-in is not enabled in Firebase Console."
            default:
                if let reason = ns.userInfo[NSLocalizedFailureReasonErrorKey] as? String, !reason.isEmpty {
                    return reason
                }
            }
        }

        if let authCode = AuthErrorCode(rawValue: code) {
            switch authCode {
            case .invalidEmail:
                return "Please enter a valid email address."
            case .weakPassword:
                return "Your password is too weak. Please use at least 6 characters."
            case .emailAlreadyInUse:
                return "This email is already in use. Try logging in instead."
            case .wrongPassword, .invalidCredential:
                return "Incorrect email or password. Please try again."
            case .userNotFound:
                return "No account found with this email. Try creating an account."
            case .tooManyRequests:
                return "Too many failed attempts. Please try again later."
            case .networkError:
                return "Network error. Check your internet connection and try again."
            case .operationNotAllowed:
                return "Email/Password sign-in is disabled in Firebase Console."
            case .invalidAPIKey:
                return "Your Firebase API key is invalid."
            case .appNotAuthorized:
                return "This app is not authorized to use Firebase Authentication."
            default:
                break
            }
        }

        if let reason = ns.userInfo[NSLocalizedFailureReasonErrorKey] as? String, !reason.isEmpty {
            return reason
        }

        let desc = ns.localizedDescription
        if !desc.isEmpty && !desc.contains("An internal error has occurred") {
            return desc
        }

        return "Sign-in error (\(domain) code \(code))."
    }
}
