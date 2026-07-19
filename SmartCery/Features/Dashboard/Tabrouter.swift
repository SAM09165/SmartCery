import Foundation
internal import Combine

enum MainTab: Hashable {
    case dashboard
    case market
    case pantry
    case groceryList
    case settings
}

@MainActor
final class TabRouter: ObservableObject {
    
    @Published var selectedTab: MainTab = .dashboard
}
