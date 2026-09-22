//
//  Tabrouter.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import Foundation
import Combine

enum MainTab: String, CaseIterable, Identifiable, Hashable {
    case dashboard = "Home"
    case mealPlanner = "Plan"
    case market = "Shop"
    case recipes = "Recipes"
    case settings = "Profile"
    case pantry = "Pantry"
    case groceryList = "List"
    case Pantry = "PantryLegacy"

    var id: String { rawValue }

    /// The 5 main tabs rendered in the floating bottom navigation bar
    static var mainTabs: [MainTab] {
        [.dashboard, .mealPlanner, .market, .recipes, .settings]
    }

    var title: String {
        switch self {
        case .dashboard: return "Home"
        case .mealPlanner: return "Plan"
        case .market: return "Shop"
        case .recipes: return "Recipes"
        case .settings: return "Profile"
        case .pantry, .Pantry: return "Pantry"
        case .groceryList: return "List"
        }
    }

    var iconName: String {
        switch self {
        case .dashboard: return "house.fill"
        case .mealPlanner: return "calendar"
        case .market: return "bag.fill"
        case .recipes: return "fork.knife"
        case .settings: return "person.fill"
        case .pantry, .Pantry: return "archivebox.fill"
        case .groceryList: return "checklist"
        }
    }
}

@MainActor
final class TabRouter: ObservableObject {
    @Published var selectedTab: MainTab = .dashboard
}
