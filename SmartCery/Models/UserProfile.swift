//
//  UserProfile.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import Foundation

enum DietaryPreference: String, Codable, CaseIterable, Identifiable {
    case pureVeg = "Strict Pure Veg"
    case eggitarian = "Eggitarian"
    case nonVeg = "Non-Vegetarian"
    case vegan = "Vegan"
    case jainVeg = "Jain Veg (No Onion/Garlic)"

    var id: String { rawValue }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if stringValue.contains("Pure Veg") || stringValue.contains("pureVeg") {
            self = .pureVeg
        } else if stringValue.contains("Eggitarian") || stringValue.contains("eggitarian") {
            self = .eggitarian
        } else if stringValue.contains("Non-Vegetarian") || stringValue.contains("nonVeg") {
            self = .nonVeg
        } else if stringValue.contains("Vegan") || stringValue.contains("vegan") {
            self = .vegan
        } else if stringValue.contains("Jain") || stringValue.contains("jainVeg") {
            self = .jainVeg
        } else if let match = DietaryPreference(rawValue: stringValue) {
            self = match
        } else {
            self = .pureVeg
        }
    }

    var isStrictVeg: Bool {
        switch self {
        case .pureVeg, .vegan, .jainVeg: return true
        default: return false
        }
    }

    var allowsEggs: Bool {
        switch self {
        case .eggitarian, .nonVeg: return true
        default: return false
        }
    }

    var allowsMeat: Bool {
        return self == .nonVeg
    }

    var badgeIcon: String {
        switch self {
        case .pureVeg, .vegan, .jainVeg: return "leaf.circle.fill"
        case .eggitarian: return "oval.portrait.fill"
        case .nonVeg: return "fork.knife.circle.fill"
        }
    }

    var description: String {
        switch self {
        case .pureVeg: return "100% Vegetarian. Strictly no eggs, meat, chicken, or seafood."
        case .eggitarian: return "Vegetarian + Eggs. Strictly no meat, chicken, or seafood."
        case .nonVeg: return "Includes Chicken, Mutton, Fish, Eggs & Vegetables."
        case .vegan: return "100 plant-based. No dairy, no eggs, no animal products."
        case .jainVeg: return "Pure Veg without onion, garlic, or root vegetables."
        }
    }
}

enum WorkoutFrequency: String, Codable, CaseIterable, Identifiable {
    case sedentary = "Sedentary (No Workout)"
    case light = "Light (1-2 days/week)"
    case moderate = "Moderate (3-4 days/week)"
    case active = "Active (5-6 days/week)"
    case intense = "Athlete / Daily Heavy Workout"

    var id: String { rawValue }

    var activityMultiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .intense: return 1.9
        }
    }
}

enum FitnessGoal: String, Codable, CaseIterable, Identifiable {
    case fatLoss = "Fat Loss / Weight Loss"
    case muscleGain = "Muscle Gain / Bulking"
    case maintenance = "Maintain Weight & Fitness"
    case zeroWaste = "Zero-Waste Clean Eating"

    var id: String { rawValue }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        if stringValue.contains("Fat Loss") {
            self = .fatLoss
        } else if stringValue.contains("Muscle Gain") {
            self = .muscleGain
        } else if stringValue.contains("Maintain") {
            self = .maintenance
        } else if stringValue.contains("Zero-Waste") {
            self = .zeroWaste
        } else if let match = FitnessGoal(rawValue: stringValue) {
            self = match
        } else {
            self = .fatLoss
        }
    }

    var calorieAdjustmentFactor: Double {
        switch self {
        case .fatLoss: return 0.80
        case .muscleGain: return 1.15
        case .maintenance, .zeroWaste: return 1.00
        }
    }
}

struct UserProfile: Codable, Equatable {
    var displayName: String
    var email: String
    var age: Int
    var gender: String
    var heightCm: Double
    var weightKg: Double
    var dietPreference: DietaryPreference
    var workoutFrequency: WorkoutFrequency
    var fitnessGoal: FitnessGoal
    var profileCompleted: Bool

    init(
        displayName: String = "Kitchen Hero",
        email: String = "user@smartcery.app",
        age: Int = 26,
        gender: String = "Male",
        heightCm: Double = 175.0,
        weightKg: Double = 70.0,
        dietPreference: DietaryPreference = .pureVeg,
        workoutFrequency: WorkoutFrequency = .moderate,
        fitnessGoal: FitnessGoal = .fatLoss,
        profileCompleted: Bool = false
    ) {
        self.displayName = displayName
        self.email = email
        self.age = age
        self.gender = gender
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.dietPreference = dietPreference
        self.workoutFrequency = workoutFrequency
        self.fitnessGoal = fitnessGoal
        self.profileCompleted = profileCompleted
    }

    var bmr: Double {
        let isFemale = gender.lowercased() == "female"
        let base = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * Double(age))
        return isFemale ? (base - 161.0) : (base + 5.0)
    }

    var tdee: Double {
        bmr * workoutFrequency.activityMultiplier
    }

    var calculatedTargetCalories: Int {
        Int((tdee * fitnessGoal.calorieAdjustmentFactor).rounded())
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
}
