import Foundation
internal import Combine

@MainActor
final class GroceryMarketViewModel: ObservableObject {
    let items: [MarketItem] = MarketCatalog.items
    let categories: [String]

    @Published private(set) var quantities: [UUID: Int] = [:]
    @Published var selectedCategory: String = "All"
    @Published var searchText: String = ""
    @Published var orderPlacedMessage: String?

    init() {
        var seen: [String] = []
        for item in MarketCatalog.items where !seen.contains(item.category) {
            seen.append(item.category)
        }
        self.categories = ["All"] + seen
    }

    var filteredItems: [MarketItem] {
        let categoryFiltered = selectedCategory == "All" ? items : items.filter { $0.category == selectedCategory }
        guard !searchText.isEmpty else { return categoryFiltered }
        return categoryFiltered.filter { item in
            item.name.localizedCaseInsensitiveContains(searchText)
                || item.category.localizedCaseInsensitiveContains(searchText)
                || item.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    // Total items across the whole cart — drives the tab badge in MainTabView
    var cartCount: Int {
        quantities.values.reduce(0, +)
    }

    var cartItems: [(item: MarketItem, quantity: Int)] {
        items.compactMap { item in
            guard let quantity = quantities[item.id], quantity > 0 else { return nil }
            return (item, quantity)
        }
    }

    var subtotal: Double {
        cartItems.reduce(0) { partialResult, cartLine in
            partialResult + (cartLine.item.price * Double(cartLine.quantity))
        }
    }

    var deliveryFee: Double {
        cartCount == 0 || subtotal >= 25 ? 0 : 2.99
    }

    var total: Double {
        subtotal + deliveryFee
    }

    var cartStatusLine: String {
        cartCount == 0
            ? "Fresh groceries delivered fast"
            : "\(cartCount) item\(cartCount == 1 ? "" : "s") · \(formatPrice(total))"
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

    func focusMarket(on neededItems: [String]) {
        selectedCategory = "All"
        searchText = neededItems.first ?? ""
    }

    func placeOrder() {
        guard cartCount > 0 else { return }
        orderPlacedMessage = "Order placed for \(cartCount) item\(cartCount == 1 ? "" : "s") · \(formatPrice(total))"
        quantities.removeAll()
    }

    func formatPrice(_ value: Double) -> String {
        String(format: "$%.2f", value)
    }
}
