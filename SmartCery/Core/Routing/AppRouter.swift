//
//  AppRouter.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI
internal import Combine

enum AppDestination {
    case loading
    case onboarding
    case auth
    case pantrySeed
    case dashboard(offline: Bool)
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var destination: AppDestination = .loading
    
    private let minimumSplashNanoseconds: UInt64 = 1_200_000_000
    
    private let mockHasCompletedOnboarding = false
    private let mockIsLoggedIn = false
    
    func resolveDestination() async {
        let hold = Task {
            try? await Task.sleep(nanoseconds: minimumSplashNanoseconds)
        }
        guard mockHasCompletedOnboarding else {
            await hold.value
            destination = .onboarding
            return
        }

        await hold.value
        destination = mockIsLoggedIn ? .dashboard(offline: false) : .auth
    }

    func completeOnboarding() {
        // TODO: Save onboarding completion with UserDefaults or Firebase user profile later.
        destination = .auth
    }

    func completeMockAuth() {
        // TODO: Replace with Firebase Auth result handling later.
        destination = .dashboard(offline: false)
    }

    func openPantrySeed() {
        destination = .pantrySeed
    }

    func completePantrySeed() {
        // TODO: Check saved pantry items before showing dashboard later.
        destination = .dashboard(offline: false)
    }

    func continueOffline() {
        destination = .dashboard(offline: true)
    }
}
