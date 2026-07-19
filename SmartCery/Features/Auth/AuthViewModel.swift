//
//  AuthViewModel.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import Foundation
internal import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isSignUpMode = true
    @Published var statusMessage = "Chef Zest says: prove you are not here to buy cilantro again."

    var title: String {
        isSignUpMode ? "Make your grocery life less chaotic." : "Welcome back, snack strategist."
    }

    var subtitle: String {
        isSignUpMode ? "Create a mock account for now. Firebase joins the kitchen later." : "Sign in with mock data and get back to saving sad vegetables."
    }

    var primaryButtonTitle: String {
        isSignUpMode ? "Create Mock Account" : "Mock Sign In"
    }

    var toggleTitle: String {
        isSignUpMode ? "Already joined the fridge cult? Sign in" : "New here? Create account"
    }

    var canSubmit: Bool {
        email.contains("@") && password.count >= 4
    }

    func toggleMode() {
        isSignUpMode.toggle()
        statusMessage = isSignUpMode ? "New account, new pantry personality." : "Welcome back. Your leftovers missed the judgment."
    }

    func submit() -> Bool {
        guard canSubmit else {
            statusMessage = "Use a real-looking email and 4+ password characters. Even roast mode has standards."
            return false
        }

        // TODO: Replace this mock success with Firebase Auth sign-in/sign-up later.
        statusMessage = isSignUpMode ? "Account created. Chef Zest is sharpening the spatula." : "Signed in. Pantry chaos detected."
        return true
    }
}
