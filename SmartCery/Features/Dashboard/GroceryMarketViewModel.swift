import Foundation
import Combine

@MainActor
final class GroceryMarketViewModel: ObservableObject {
    let items: [MarketItem] = MarketCatalog.items

    @Published private(set) var quantities: [UUID: Int] = [:]
    @Published var selectedCategory: String = "All"
    @Published var searchText: String = ""
    @Published var deliveryAddress: String = "Home · 21 Park Street, Suite 4B"
    @Published var promoCode: String = ""
    @Published var discountAmount: Double = 0
    @Published var activeOrder: MarketOrder?

    // Dietary filtering & User profile awareness
    @Published var isVegOnlyMode: Bool = true
    @Published var userDietPreference: DietaryPreference = .pureVeg

    struct MarketOrder: Identifiable {
        let id = UUID()
        let items: [(item: MarketItem, quantity: Int)]
        let total: Double
        let timestamp = Date()
        var step: Int = 1 // 1: Confirmed, 2: Packing, 3: Out for Delivery, 4: Delivered
        var deliveryAddress: String = "Home • 21 Park Street, Suite 4B"

        var estimatedMinutesRemaining: Int {
            switch step {
            case 1: return 10
            case 2: return 7
            case 3: return 3
            default: return 0
            }
        }

        var status: String {
            switch step {
            case 1: return "Order Confirmed"
            case 2: return "Packing at Dark Store"
            case 3: return "Out for Delivery"
            default: return "Delivered"
            }
        }
    }

    init() {
        // Default initialized in pure veg safe mode
        self.isVegOnlyMode = true
    }

    func syncDiet(from preference: DietaryPreference?) {
        guard let preference = preference else { return }
        self.userDietPreference = preference
        if preference.isStrictVeg {
            self.isVegOnlyMode = true
        } else {
            self.isVegOnlyMode = false
        }
    }

    var categories: [String] {
        let allowed = allowedCatalogItems
        var seen: [String] = []
        for item in allowed where !seen.contains(item.category) {
            seen.append(item.category)
        }
        return ["All"] + seen
    }

    var allowedCatalogItems: [MarketItem] {
        if isVegOnlyMode || userDietPreference.isStrictVeg {
            return items.filter { $0.dietType == .pureVeg }
        } else if userDietPreference == .eggitarian {
            return items.filter { $0.dietType == .pureVeg || $0.dietType == .egg }
        } else {
            return items
        }
    }

    var filteredItems: [MarketItem] {
        var result = allowedCatalogItems

        if selectedCategory != "All" {
            result = result.filter { $0.category == selectedCategory }
        }

        guard !searchText.isEmpty else { return result }
        return result.filter { item in
            item.name.localizedCaseInsensitiveContains(searchText)
                || item.category.localizedCaseInsensitiveContains(searchText)
                || item.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var smartReplenishItems: [MarketItem] {
        Array(allowedCatalogItems.prefix(4))
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

    var handlingFee: Double {
        cartCount == 0 ? 0 : 0.99
    }

    var deliveryFee: Double {
        cartCount == 0 || subtotal >= 25 ? 0 : 2.99
    }

    var total: Double {
        max(0, subtotal - discountAmount) + deliveryFee
    }

    var cartStatusLine: String {
        cartCount == 0
            ? "10 min express delivery"
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

    func clearCart() {
        quantities.removeAll()
    }

    func addBundle(itemNames: [String]) {
        for name in itemNames {
            if let matched = allowedCatalogItems.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame || $0.name.localizedCaseInsensitiveContains(name) }) {
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

    func icon(for category: String) -> String {
        switch category.lowercased() {
        case "all": return "sparkles"
        case "produce": return "leaf.fill"
        case "dairy": return "cup.and.saucer.fill"
        case "bakery": return "birthday.cake.fill"
        case "pantry": return "takeoutbag.and.cup.and.straw.fill"
        case "condiments": return "flame.fill"
        case "eggs": return "oval.fill"
        case "meat": return "fish.fill"
        default: return "bag.fill"
        }
    }
}


typealias MarketOrder = GroceryMarketViewModel.MarketOrder
