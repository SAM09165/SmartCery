//
//  AppRouter.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI
import Combine

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
    
    func resolveDestination() async {
        let hold = Task {
            try? await Task.sleep(nanoseconds: minimumSplashNanoseconds)
        }
        guard UserDefaults.standard.bool(forKey: "smartcery.onboarding-complete") else {
            await hold.value
            destination = .onboarding
            return
        }

        await hold.value
        destination = UserDefaults.standard.bool(forKey: "smartcery.has-profile") ? .dashboard(offline: false) : .auth
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "smartcery.onboarding-complete")
        destination = .auth
    }

    func completeMockAuth() {
        UserDefaults.standard.set(true, forKey: "smartcery.has-profile")
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
