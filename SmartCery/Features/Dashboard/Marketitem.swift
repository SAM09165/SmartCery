import Foundation

struct MarketItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let price: Double
    let unit: String
    let expiryWindow: String
    let origin: String
    let deliveryEstimate: String
    let stockCount: Int
    let details: String
    let tags: [String]
    let iconName: String

    var isLowStock: Bool {
        stockCount <= 8
    }
}

enum MarketCatalog {
    static let items: [MarketItem] = [
        MarketItem(
            name: "Whole Milk",
            category: "Dairy",
            price: 3.49,
            unit: "1 L carton",
            expiryWindow: "5 days",
            origin: "Green Valley Dairy",
            deliveryEstimate: "Today, 25-35 min",
            stockCount: 18,
            details: "Pasteurized full-cream milk for breakfast, tea, sauces, and baking.",
            tags: ["Calcium", "Chilled", "Vegetarian"],
            iconName: "drop.fill"
        ),
        MarketItem(
            name: "Large Eggs (12)",
            category: "Dairy",
            price: 4.29,
            unit: "12 pcs",
            expiryWindow: "14 days",
            origin: "Sunny Farm Co.",
            deliveryEstimate: "Today, 25-35 min",
            stockCount: 22,
            details: "Grade A eggs for omelettes, baking, fried rice, and meal prep.",
            tags: ["Protein", "Breakfast", "Meal prep"],
            iconName: "oval.fill"
        ),
        MarketItem(
            name: "Greek Yogurt",
            category: "Dairy",
            price: 4.79,
            unit: "500 g tub",
            expiryWindow: "7 days",
            origin: "Cultured Kitchen",
            deliveryEstimate: "Today, 30-40 min",
            stockCount: 7,
            details: "Thick strained yogurt for bowls, marinades, dips, and smoothies.",
            tags: ["High protein", "Chilled", "No added sugar"],
            iconName: "cup.and.saucer.fill"
        ),
        MarketItem(
            name: "Sourdough Bread",
            category: "Bakery",
            price: 5.99,
            unit: "1 loaf",
            expiryWindow: "3 days",
            origin: "Old Mill Bakery",
            deliveryEstimate: "Today, 20-30 min",
            stockCount: 5,
            details: "Naturally leavened loaf with a crisp crust for toast, soup, and sandwiches.",
            tags: ["Fresh baked", "Vegetarian", "Soup pair"],
            iconName: "birthday.cake.fill"
        ),
        MarketItem(
            name: "Bananas",
            category: "Produce",
            price: 1.29,
            unit: "6 pcs",
            expiryWindow: "4 days",
            origin: "Tropical Farms",
            deliveryEstimate: "Today, 20-30 min",
            stockCount: 31,
            details: "Ripe yellow bananas for snacks, oats, smoothies, and baking.",
            tags: ["Fruit", "Fiber", "Snack"],
            iconName: "leaf.fill"
        ),
        MarketItem(
            name: "Roma Tomatoes",
            category: "Produce",
            price: 2.49,
            unit: "500 g pack",
            expiryWindow: "5 days",
            origin: "Local Growers Market",
            deliveryEstimate: "Today, 25-35 min",
            stockCount: 16,
            details: "Firm tomatoes for salads, sauces, curries, and quick soups.",
            tags: ["Fresh", "Sauce base", "Vegan"],
            iconName: "circle.fill"
        ),
        MarketItem(
            name: "Cherry Tomatoes",
            category: "Produce",
            price: 3.19,
            unit: "250 g box",
            expiryWindow: "5 days",
            origin: "Local Growers Market",
            deliveryEstimate: "Today, 25-35 min",
            stockCount: 12,
            details: "Sweet bite-sized tomatoes for salads, pasta, and grilled paneer bowls.",
            tags: ["Fresh", "Salad", "Vegan"],
            iconName: "circle.grid.cross.fill"
        ),
        MarketItem(
            name: "Spinach",
            category: "Produce",
            price: 2.99,
            unit: "1 bunch",
            expiryWindow: "3 days",
            origin: "Hydro Fresh",
            deliveryEstimate: "Today, 20-30 min",
            stockCount: 9,
            details: "Tender spinach for wraps, soups, omelettes, and quick stir-fries.",
            tags: ["Iron", "Leafy greens", "Quick cook"],
            iconName: "leaf.fill"
        ),
        MarketItem(
            name: "Chicken Breast",
            category: "Meat",
            price: 8.99,
            unit: "500 g pack",
            expiryWindow: "2 days",
            origin: "Prime Poultry",
            deliveryEstimate: "Today, 35-45 min",
            stockCount: 6,
            details: "Boneless chicken breast for grilling, curries, salads, and batch cooking.",
            tags: ["High protein", "Chilled", "Lean"],
            iconName: "fish.fill"
        ),
        MarketItem(
            name: "Basmati Rice",
            category: "Pantry",
            price: 6.49,
            unit: "2 kg bag",
            expiryWindow: "12 months",
            origin: "Harvest Select",
            deliveryEstimate: "Today, 25-35 min",
            stockCount: 40,
            details: "Aromatic long-grain rice for bowls, biryani, dal, and weekly meal prep.",
            tags: ["Pantry", "Long shelf life", "Vegan"],
            iconName: "takeoutbag.and.cup.and.straw.fill"
        ),
        MarketItem(
            name: "Olive Oil",
            category: "Pantry",
            price: 9.99,
            unit: "500 ml bottle",
            expiryWindow: "10 months",
            origin: "Mediterranean Press",
            deliveryEstimate: "Today, 30-40 min",
            stockCount: 14,
            details: "Extra virgin olive oil for dressings, sauteing, roasting, and finishing.",
            tags: ["Pantry", "Heart healthy", "Vegan"],
            iconName: "drop.triangle.fill"
        ),
        MarketItem(
            name: "Mint Chutney",
            category: "Condiments",
            price: 3.29,
            unit: "200 g jar",
            expiryWindow: "21 days",
            origin: "Spice Route",
            deliveryEstimate: "Today, 25-35 min",
            stockCount: 11,
            details: "Bright mint and coriander chutney for wraps, bowls, snacks, and marinades.",
            tags: ["Ready to eat", "Vegetarian", "Zesty"],
            iconName: "takeoutbag.and.cup.and.straw.fill"
        ),
        MarketItem(
            name: "Lemon",
            category: "Produce",
            price: 0.79,
            unit: "1 pc",
            expiryWindow: "10 days",
            origin: "Citrus Grove",
            deliveryEstimate: "Today, 20-30 min",
            stockCount: 35,
            details: "Fresh lemon for dressings, pasta, tea, marinades, and finishing.",
            tags: ["Citrus", "Fresh", "Vegan"],
            iconName: "circle.lefthalf.filled"
        ),
        MarketItem(
            name: "Parsley",
            category: "Produce",
            price: 1.49,
            unit: "1 bunch",
            expiryWindow: "4 days",
            origin: "Hydro Fresh",
            deliveryEstimate: "Today, 20-30 min",
            stockCount: 8,
            details: "Fresh parsley for pasta, salads, soups, and herb sauces.",
            tags: ["Herbs", "Fresh", "Vegan"],
            iconName: "leaf.fill"
        ),
        MarketItem(
            name: "Blueberries",
            category: "Produce",
            price: 4.49,
            unit: "125 g box",
            expiryWindow: "5 days",
            origin: "Berry Patch",
            deliveryEstimate: "Today, 30-40 min",
            stockCount: 10,
            details: "Sweet blueberries for oats, yogurt bowls, smoothies, and snacks.",
            tags: ["Fruit", "Antioxidants", "Breakfast"],
            iconName: "circle.grid.2x2.fill"
        )
    ]
}
