import Foundation
internal import Combine

enum MainTab: Hashable {
    case dashboard
    case market
    case pantry
    case mealPlanner
    case groceryList
    case settings
    case Pantry
}

@MainActor
final class TabRouter: ObservableObject {
    
    @Published var selectedTab: MainTab = .dashboard
}
