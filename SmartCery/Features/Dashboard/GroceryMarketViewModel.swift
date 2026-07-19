import Foundation
internal import Combine

@MainActor
final class GroceryMarketViewModel: ObservableObject {
    let items: [MarketItem] = MarketCatalog.items
    let categories: [String]

    @Published private(set) var quantities: [UUID: Int] = [:]
    @Published var selectedCategory: String = "All"

    init() {
        var seen: [String] = []
        for item in MarketCatalog.items where !seen.contains(item.category) {
            seen.append(item.category)
        }
        self.categories = ["All"] + seen
    }

    var filteredItems: [MarketItem] {
        selectedCategory == "All" ? items : items.filter { $0.category == selectedCategory }
    }

    // Total items across the whole cart — drives the tab badge in MainTabView
    var cartCount: Int {
        quantities.values.reduce(0, +)
    }

    func quantity(for item: MarketItem) -> Int {
        quantities[item.id] ?? 0
    }

    func increment(_ item: MarketItem) {
        quantities[item.id, default: 0] += 1
    }

    func decrement(_ item: MarketItem) {
        guard let current = quantities[item.id], current > 0 else { return }
        if current == 1 {
            quantities.removeValue(forKey: item.id)
        } else {
            quantities[item.id] = current - 1
        }
    }
}
