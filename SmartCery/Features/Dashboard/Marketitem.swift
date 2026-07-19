import Foundation

struct MarketItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let price: Double
    let iconName: String
}

enum MarketCatalog {
    static let items: [MarketItem] = [
        MarketItem(name: "Whole Milk", category: "Dairy", price: 3.49, iconName: "drop.fill"),
        MarketItem(name: "Large Eggs (12)", category: "Dairy", price: 4.29, iconName: "oval.fill"),
        MarketItem(name: "Greek Yogurt", category: "Dairy", price: 4.79, iconName: "cup.and.saucer.fill"),
        MarketItem(name: "Sourdough Bread", category: "Bakery", price: 5.99, iconName: "birthday.cake.fill"),
        MarketItem(name: "Bananas", category: "Produce", price: 1.29, iconName: "leaf.fill"),
        MarketItem(name: "Roma Tomatoes", category: "Produce", price: 2.49, iconName: "circle.fill"),
        MarketItem(name: "Spinach", category: "Produce", price: 2.99, iconName: "leaf.fill"),
        MarketItem(name: "Chicken Breast", category: "Meat", price: 8.99, iconName: "fish.fill"),
        MarketItem(name: "Basmati Rice", category: "Pantry", price: 6.49, iconName: "takeoutbag.and.cup.and.straw.fill"),
        MarketItem(name: "Olive Oil", category: "Pantry", price: 9.99, iconName: "drop.triangle.fill")
    ]
}
