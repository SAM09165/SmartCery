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

    // Personal Details Intake State
    @Published var displayName: String = "Kitchen Hero"
    @Published var age: Int = 25
    @Published var gender: String = "Male"
    @Published var heightCm: Double = 172.0
    @Published var weightKg: Double = 68.0
    @Published var dietPreference: DietaryPreference = .pureVeg
    @Published var workoutFrequency: WorkoutFrequency = .moderate
    @Published var fitnessGoal: FitnessGoal = .fatLoss

    let pages = CopyBank.onboardingPages

    var isIntakePage: Bool {
        currentPageIndex == pages.count
    }

    var isLastPage: Bool {
        currentPageIndex == pages.count
    }

    var primaryButtonTitle: String {
        isIntakePage ? "Save & Start Cooking" : "Next"
    }

    var calculatedBMR: Double {
        let isFemale = gender.lowercased() == "female"
        let base = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * Double(age))
        return isFemale ? (base - 161.0) : (base + 5.0)
    }

    var calculatedTDEE: Double {
        calculatedBMR * workoutFrequency.activityMultiplier
    }

    var calculatedTargetCalories: Int {
        Int((calculatedTDEE * fitnessGoal.calorieAdjustmentFactor).rounded())
    }

    var calculatedTargetProtein: Int {
        switch fitnessGoal {
        case .muscleGain:
            return Int((weightKg * 2.0).rounded())
        case .fatLoss:
            return Int((weightKg * 1.8).rounded())
        default:
            return Int((weightKg * 1.4).rounded())
        }
    }

    func goNext() {
        if currentPageIndex <= pages.count {
            currentPageIndex += 1
        }
    }

    func skipToLastPage() {
        currentPageIndex = pages.count
    }

    func buildUserProfile() -> UserProfile {
        UserProfile(
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Kitchen Hero" : displayName,
            email: "user@smartcery.app",
            age: age,
            gender: gender,
            heightCm: heightCm,
            weightKg: weightKg,
            dietPreference: dietPreference,
            workoutFrequency: workoutFrequency,
            fitnessGoal: fitnessGoal
        )
    }
}
