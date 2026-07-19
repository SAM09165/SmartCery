//
//  RootView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Group {
            switch router.destination {
            case .loading:
                SplashView()
            case .onboarding:
                OnboardingView()
            case .auth:
                AuthView()
            case .pantrySeed:
                PantrySeedView()
            case .dashboard:
                MainTabView()
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppRouter())
}
