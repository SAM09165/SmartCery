//
//  DashboardViewModel.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI
import Combine

struct DashboardStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let iconName: String
}

enum TimeOfDay {
    case morning, afternoon, evening, night

    var title: String {
        switch self {
        case .morning: return "Good Morning"
        case .afternoon: return "Good Afternoon"
        case .evening: return "Good Evening"
        case .night: return "Night Reset"
        }
    }

    var iconName: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.stars.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .morning: return "Fresh breakfast prep ready in your kitchen."
        case .afternoon: return "Quick lunch matches from your current pantry."
        case .evening: return "Time for dinner prep! Rescue expiring items."
        case .night: return "Late night kitchen rest! Plan tomorrow with Chef Zest."
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .morning:
            return [Color(red: 0.98, green: 0.65, blue: 0.32), AppTheme.zestOrange]
        case .afternoon:
            return [AppTheme.basilGreen, Color(red: 0.22, green: 0.58, blue: 0.45)]
        case .evening:
            return [AppTheme.zestOrange, Color(red: 0.88, green: 0.38, blue: 0.22)]
        case .night:
            return [Color(red: 0.12, green: 0.22, blue: 0.35), AppTheme.basilGreen]
        }
    }
}

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var timeOfDay: TimeOfDay = .morning

    let livePromos: [String] = [
        "FLASH PREP: 15-Min Pantry Meal Ideas Active",
        "LIVE SYNC: Pantry inventory updated in real time",
        "CHEF ZEST: Zero-waste recipe recommendations ready",
        "SMART MARKET: 1-Tap auto fill missing recipe ingredients"
    ]

    let greeting = "Welcome back."
    let chefLine = "Chef Zest report: Your pantry has fresh essentials ready for quick, balanced meals today."

    init() {
        updateTimeOfDay()
    }

    func updateTimeOfDay() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            timeOfDay = .morning
        case 12..<17:
            timeOfDay = .afternoon
        case 17..<21:
            timeOfDay = .evening
        default:
            timeOfDay = .night
        }
    }
}
