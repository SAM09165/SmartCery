import Foundation
import Combine

@MainActor
final class GroceryMarketViewModel: ObservableObject {
    let items: [MarketItem] = MarketCatalog.items
    let categories: [String]

    @Published private(set) var quantities: [UUID: Int] = [:]
    @Published var selectedCategory: String = "All"
    @Published var searchText: String = ""
    @Published var deliveryAddress: String = "Home · 21 Park Street, Suite 4B"
    @Published var promoCode: String = ""
    @Published var discountAmount: Double = 0
    @Published var activeOrder: MarketOrder?

    struct MarketOrder: Identifiable {
        let id = UUID()
        let items: [(item: MarketItem, quantity: Int)]
        let total: Double
        let timestamp = Date()
        var step: Int = 1 // 1: Confirmed, 2: Packing, 3: Out for Delivery, 4: Delivered
    }

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
        max(0, subtotal - discountAmount) + deliveryFee
    }

    var cartStatusLine: String {
        cartCount == 0
            ? "⚡ 15 min express delivery"
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

    func addBundle(itemNames: [String]) {
        for name in itemNames {
            if let matched = items.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame || $0.name.localizedCaseInsensitiveContains(name) }) {
                increment(matched)
            }
        }
    }

    func focusMarket(on neededItems: [String]) {
        selectedCategory = "All"
        searchText = neededItems.first ?? ""
    }

    func applyPromo() {
        let clean = promoCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if clean == "SMART20" || clean == "ZEST10" {
            discountAmount = 3.00
        } else {
            discountAmount = 0
        }
    }

    func placeOrder() {
        guard cartCount > 0 else { return }
        let currentCart = cartItems
        let finalTotal = total
        activeOrder = MarketOrder(items: currentCart, total: finalTotal, step: 1)
        quantities.removeAll()
        discountAmount = 0
        promoCode = ""
    }

    func formatPrice(_ value: Double) -> String {
        String(format: "$%.2f", value)
    }
}
