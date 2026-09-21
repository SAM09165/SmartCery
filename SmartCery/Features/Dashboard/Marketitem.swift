import Foundation

enum MarketItemDiet: String, Codable, CaseIterable {
    case pureVeg = "Veg"
    case egg = "Egg"
    case nonVeg = "Non-Veg"
}

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
    var imageURL: String? = nil
    var dietType: MarketItemDiet = .pureVeg

    var isLowStock: Bool {
        stockCount <= 8
    }

    var isVegetarian: Bool {
        dietType == .pureVeg
    }

    var isEgg: Bool {
        dietType == .egg
    }

    var isNonVeg: Bool {
        dietType == .nonVeg
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
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 18,
            details: "Pasteurized full-cream milk for breakfast, tea, sauces, and baking.",
            tags: ["Calcium", "Chilled", "Vegetarian"],
            iconName: "drop.fill",
            imageURL: "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Fresh Paneer",
            category: "Dairy",
            price: 3.99,
            unit: "250 g block",
            expiryWindow: "5 days",
            origin: "Artisan Dairy",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 14,
            details: "Soft, rich cottage cheese ideal for palak paneer, tikka, and curries.",
            tags: ["High protein", "Fresh", "Vegetarian"],
            iconName: "square.fill",
            imageURL: "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Greek Yogurt",
            category: "Dairy",
            price: 4.79,
            unit: "500 g tub",
            expiryWindow: "7 days",
            origin: "Cultured Kitchen",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 7,
            details: "Thick strained yogurt for bowls, marinades, dips, and smoothies.",
            tags: ["High protein", "Chilled", "Vegetarian"],
            iconName: "cup.and.saucer.fill",
            imageURL: "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Pure Butter",
            category: "Dairy",
            price: 3.79,
            unit: "250 g block",
            expiryWindow: "30 days",
            origin: "Valley Dairy",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 17,
            details: "Creamy salted butter for spreads, baking, parathas, and cooking.",
            tags: ["Dairy", "Rich", "Vegetarian"],
            iconName: "cube.fill",
            imageURL: "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Sourdough Bread",
            category: "Bakery",
            price: 5.99,
            unit: "1 loaf",
            expiryWindow: "3 days",
            origin: "Old Mill Bakery",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 5,
            details: "Naturally leavened loaf with a crisp crust for toast, soup, and sandwiches.",
            tags: ["Fresh baked", "Vegetarian", "Bakery"],
            iconName: "birthday.cake.fill",
            imageURL: "https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Organic Roma Tomatoes",
            category: "Produce",
            price: 2.99,
            unit: "500 g pack",
            expiryWindow: "6 days",
            origin: "Sun Farm Organics",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 25,
            details: "Plum, deep red tomatoes suited for Indian curries, salads, and fresh salsa.",
            tags: ["Fresh", "Produce", "Vegetarian", "Vegan"],
            iconName: "circle.fill",
            imageURL: "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Fresh Baby Spinach",
            category: "Produce",
            price: 2.49,
            unit: "200 g bag",
            expiryWindow: "4 days",
            origin: "Green Valley Farm",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 16,
            details: "Washed and ready baby spinach for palak paneer, wraps, smoothies, and dal.",
            tags: ["Iron rich", "Green", "Vegetarian", "Vegan"],
            iconName: "leaf.fill",
            imageURL: "https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Sweet Red Onions",
            category: "Produce",
            price: 1.99,
            unit: "1 kg bag",
            expiryWindow: "14 days",
            origin: "Punjab Agritech",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 30,
            details: "Crisp red onions essential for tadka, salads, curries, and parathas.",
            tags: ["Pantry staple", "Vegetarian", "Vegan"],
            iconName: "circle.dashed",
            imageURL: "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Golden Yukon Potatoes",
            category: "Produce",
            price: 2.79,
            unit: "1 kg bag",
            expiryWindow: "21 days",
            origin: "Highland Farms",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 20,
            details: "Buttery all-purpose potatoes perfect for aloo jeera, roasting, and curries.",
            tags: ["Carbs", "Staple", "Vegetarian", "Vegan"],
            iconName: "circle.grid.2x2.fill",
            imageURL: "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Tri-Color Bell Peppers",
            category: "Produce",
            price: 3.49,
            unit: "3 pcs pack",
            expiryWindow: "7 days",
            origin: "Hydro Fresh Ltd.",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 12,
            details: "Crunchy red, yellow, and green bell peppers for fajitas, stir-fries, and pasta.",
            tags: ["Vitamin C", "Fresh", "Vegetarian", "Vegan"],
            iconName: "shield.fill",
            imageURL: "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Crisp Carrots",
            category: "Produce",
            price: 1.79,
            unit: "500 g pack",
            expiryWindow: "10 days",
            origin: "Organic Roots",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 19,
            details: "Sweet, crunchy carrots great for healthy snacking, soups, and curries.",
            tags: ["Vitamin A", "Fresh", "Vegetarian", "Vegan"],
            iconName: "pencil.tip",
            imageURL: "https://images.unsplash.com/photo-1598170845058-32b9d6a5c317?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Fresh Broccoli",
            category: "Produce",
            price: 2.49,
            unit: "1 head (400g)",
            expiryWindow: "5 days",
            origin: "Coast Organics",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 11,
            details: "Tender green broccoli florets high in antioxidants and dietary fiber.",
            tags: ["Fiber", "Green", "Vegetarian", "Vegan"],
            iconName: "tree.fill",
            imageURL: "https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Basmati Rice",
            category: "Pantry",
            price: 6.49,
            unit: "2 kg bag",
            expiryWindow: "12 months",
            origin: "Harvest Select",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 40,
            details: "Aromatic extra-long grain rice for biryani, pulao, and everyday meals.",
            tags: ["Pantry", "Long shelf life", "Vegetarian", "Vegan"],
            iconName: "takeoutbag.and.cup.and.straw.fill",
            imageURL: "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Olive Oil",
            category: "Pantry",
            price: 9.99,
            unit: "500 ml bottle",
            expiryWindow: "10 months",
            origin: "Mediterranean Press",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 14,
            details: "Cold-pressed extra virgin olive oil for salads, roasting, and sautéing.",
            tags: ["Pantry", "Heart healthy", "Vegetarian", "Vegan"],
            iconName: "drop.triangle.fill",
            imageURL: "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Mint Chutney",
            category: "Condiments",
            price: 3.29,
            unit: "200 g jar",
            expiryWindow: "21 days",
            origin: "Spice Route",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 11,
            details: "Fresh fragrant mint and coriander green chutney made with green chilies, cumin, and lemon.",
            tags: ["Ready to eat", "Vegetarian", "Vegan", "Zesty"],
            iconName: "leaf.fill",
            imageURL: "https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Lemon",
            category: "Produce",
            price: 0.79,
            unit: "1 pc",
            expiryWindow: "10 days",
            origin: "Citrus Grove",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 35,
            details: "Juicy fresh lemon for seasonings, teas, curries, and marinades.",
            tags: ["Citrus", "Fresh", "Vegetarian", "Vegan"],
            iconName: "circle.lefthalf.filled",
            imageURL: "https://images.unsplash.com/photo-1533082624353-de52c328b44b?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Parsley",
            category: "Produce",
            price: 1.49,
            unit: "1 bunch",
            expiryWindow: "4 days",
            origin: "Hydro Fresh",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 8,
            details: "Fresh fragrant parsley for garnishes, sauces, and pasta.",
            tags: ["Herbs", "Fresh", "Vegetarian", "Vegan"],
            iconName: "leaf.fill",
            imageURL: "https://images.unsplash.com/photo-1608797178974-15b35a61dd75?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Blueberries",
            category: "Produce",
            price: 4.49,
            unit: "125 g box",
            expiryWindow: "5 days",
            origin: "Berry Patch",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 10,
            details: "Sweet antioxidant-packed blueberries for yogurt bowls and snacking.",
            tags: ["Fruit", "Antioxidants", "Vegetarian", "Vegan"],
            iconName: "circle.grid.2x2.fill",
            imageURL: "https://images.unsplash.com/photo-1498557850523-fd3d118b962e?w=500&auto=format&fit=crop&q=80",
            dietType: .pureVeg
        ),
        MarketItem(
            name: "Large Eggs (12)",
            category: "Eggs",
            price: 4.29,
            unit: "12 pcs carton",
            expiryWindow: "14 days",
            origin: "Sunny Farm Co.",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 22,
            details: "Grade A fresh brown eggs for omelettes, baking, and protein bowls.",
            tags: ["Protein", "Breakfast", "Egg"],
            iconName: "oval.fill",
            imageURL: "https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=500&auto=format&fit=crop&q=80",
            dietType: .egg
        ),
        MarketItem(
            name: "Chicken Breast",
            category: "Meat",
            price: 8.99,
            unit: "500 g pack",
            expiryWindow: "2 days",
            origin: "Prime Poultry",
            deliveryEstimate: "Today, 10-15 min",
            stockCount: 6,
            details: "Fresh lean boneless chicken breast for grilling, curries, and meal prep.",
            tags: ["High protein", "Chilled", "Lean", "Non-Veg"],
            iconName: "fish.fill",
            imageURL: "https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500&auto=format&fit=crop&q=80",
            dietType: .nonVeg
        )
    ]
}
