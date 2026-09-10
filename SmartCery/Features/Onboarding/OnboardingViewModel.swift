//
//  OnboardingViewModel.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import Foundation
import Combine

struct OnboardingPage: Identifiable {
    let id = UUID()
    let iconName: String
    let eyebrow: String
    let title: String
    let message: String
    let chefLine: String
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPageIndex = 0

    let pages = CopyBank.onboardingPages

    var isLastPage: Bool {
        currentPageIndex == pages.count - 1
    }

    var primaryButtonTitle: String {
        isLastPage ? "Start Cooking" : "Next"
    }

    func goNext() {
        guard !isLastPage else { return }
        currentPageIndex += 1
    }

    func skipToLastPage() {
        currentPageIndex = pages.count - 1
    }
}
