//
//  DailyThemeCatalog.swift
//  SmartCery
//
//  30-Day Dynamic Hero Banner Catalog with Veg & Non-Veg Product Personalization.
//  Inspired by quick-commerce dynamic advertising banners (Blinkit style).
//

import SwiftUI

struct PromotedProduct: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let iconName: String
    let emoji: String
    let tag: String
    let category: String
}

struct BannerCategoryTile: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let filterCategory: String
}

struct DailyThemeVariant {
    let title: String
    let subtitle: String
    let badgeText: String
    let gradientColors: [Color]
    let accentColor: Color
    let promotedProducts: [PromotedProduct]
    let quickCategories: [BannerCategoryTile]
    let tickerText: String
    let tickerSubtitle: String
    let ctaText: String
}

struct DailyTheme {
    let dayNumber: Int
    let themeName: String
    let vegDayVariant: DailyThemeVariant
    let vegNightVariant: DailyThemeVariant
    let nonVegDayVariant: DailyThemeVariant
    let nonVegNightVariant: DailyThemeVariant

    func currentVariant(isNight: Bool, diet: DietaryPreference) -> DailyThemeVariant {
        let isVeg = diet.isStrictVeg
        if isVeg {
            return isNight ? vegNightVariant : vegDayVariant
        } else {
            return isNight ? nonVegNightVariant : nonVegDayVariant
        }
    }
}

enum DailyThemeCatalog {
    static func theme(for dayNumber: Int) -> DailyTheme {
        let index = max(1, min(30, dayNumber))
        return themes[index - 1]
    }

    static func currentTheme(
        dayOverride: Int? = nil,
        overrideIsNight: Bool? = nil,
        dietPreference: DietaryPreference = .pureVeg
    ) -> (variant: DailyThemeVariant, dayNumber: Int) {
        let calendar = Calendar.current
        let currentDayOfMonth = calendar.component(.day, from: Date())
        let dayNumber = dayOverride ?? max(1, min(30, currentDayOfMonth))
        let hour = calendar.component(.hour, from: Date())
        let isNight = overrideIsNight ?? (hour < 6 || hour >= 18)

        let theme = themes[dayNumber - 1]
        let variant = theme.currentVariant(isNight: isNight, diet: dietPreference)
        return (variant, dayNumber)
    }

    static let themes: [DailyTheme] = (1...30).map { day in
        generateTheme(for: day)
    }

    private static func generateTheme(for day: Int) -> DailyTheme {
        switch day {
        case 1:
            return DailyTheme(
                dayNumber: 1,
                themeName: "Morning Protein Power",
                vegDayVariant: DailyThemeVariant(
                    title: "POWER YOUR DAY WITH SOYA & PANEER",
                    subtitle: "Farm-fresh malai paneer & high-protein soya chunks delivered in 10 mins.",
                    badgeText: "HIGH PROTEIN VEG • DAY 1",
                    gradientColors: [Color(red: 0.12, green: 0.48, blue: 0.28), Color(red: 0.05, green: 0.28, blue: 0.16)],
                    accentColor: Color(red: 0.98, green: 0.82, blue: 0.28),
                    promotedProducts: [
                        PromotedProduct(name: "Fresh Malai Paneer", subtitle: "200g • ₹95", iconName: "square.fill", emoji: "🧀", tag: "18g Protein", category: "Dairy"),
                        PromotedProduct(name: "High-Protein Soya Chunks", subtitle: "250g • ₹45", iconName: "circle.grid.2x2.fill", emoji: "🫘", tag: "52g Protein", category: "Pantry")
                    ],
                    quickCategories: [
                        BannerCategoryTile(title: "Paneer", subtitle: "Fresh Dairy", iconName: "drop.fill", filterCategory: "Dairy"),
                        BannerCategoryTile(title: "Soya Chunks", subtitle: "High Protein", iconName: "leaf.fill", filterCategory: "Pantry"),
                        BannerCategoryTile(title: "Green Veggies", subtitle: "Organic", iconName: "circle.fill", filterCategory: "Produce"),
                        BannerCategoryTile(title: "Tofu", subtitle: "Vegan Protein", iconName: "square.grid.2x2.fill", filterCategory: "Dairy")
                    ],
                    tickerText: "100% Pure Plant Protein Bowl Recipes",
                    tickerSubtitle: "Explore Chef Zest's 15-minute Paneer Soya Bhurji",
                    ctaText: "Shop Veg Protein"
                ),
                vegNightVariant: DailyThemeVariant(
                    title: "MIDNIGHT SOYA & WARM TIKKA CRAVINGS",
                    subtitle: "Cozy night Soya Tikka & warm herbal chai for a soothing end to Day 1.",
                    badgeText: "NIGHT RESET MODE • DAY 1",
                    gradientColors: [Color(red: 0.15, green: 0.22, blue: 0.38), Color(red: 0.06, green: 0.10, blue: 0.22)],
                    accentColor: Color(red: 0.42, green: 0.85, blue: 0.98),
                    promotedProducts: [
                        PromotedProduct(name: "Tandoori Soya Chaap", subtitle: "Marinated • ₹160", iconName: "sparkles", emoji: "🍢", tag: "Chef Pick", category: "Pantry"),
                        PromotedProduct(name: "Warm Chamomile Tea", subtitle: "25 Bags • ₹180", iconName: "mug.fill", emoji: "🍵", tag: "Sleep Well", category: "Pantry")
                    ],
                    quickCategories: [
                        BannerCategoryTile(title: "Night Snacks", subtitle: "Light & Healthy", iconName: "moon.stars.fill", filterCategory: "Pantry"),
                        BannerCategoryTile(title: "Warm Teas", subtitle: "Relaxing", iconName: "cup.and.saucer.fill", filterCategory: "Pantry"),
                        BannerCategoryTile(title: "Dark Choco", subtitle: "Zero Guilt", iconName: "heart.fill", filterCategory: "Bakery"),
                        BannerCategoryTile(title: "Almond Milk", subtitle: "Dairy Free", iconName: "drop.triangle.fill", filterCategory: "Dairy")
                    ],
                    tickerText: "Late Night Soya Tikka Recipe Ready!",
                    tickerSubtitle: "Made in 10 mins with zero guilt",
                    ctaText: "Order Late Snacks"
                ),
                nonVegDayVariant: DailyThemeVariant(
                    title: "GIVES YOU WINGS: FRESH EGGS & MEAT",
                    subtitle: "Farm-fresh organic brown eggs & juicy chicken breasts at express delivery.",
                    badgeText: "POWER MEAT & EGGS • DAY 1",
                    gradientColors: [Color(red: 0.10, green: 0.25, blue: 0.55), Color(red: 0.05, green: 0.12, blue: 0.32)],
                    accentColor: Color(red: 0.98, green: 0.65, blue: 0.22),
                    promotedProducts: [
                        PromotedProduct(name: "Organic Farm Eggs", subtitle: "Pack of 6 • ₹85", iconName: "oval.fill", emoji: "🥚", tag: "Fresh Daily", category: "Meat & Eggs"),
                        PromotedProduct(name: "Tender Chicken Breast", subtitle: "500g • ₹240", iconName: "flame.fill", emoji: "🍗", tag: "31g Protein", category: "Meat & Eggs")
                    ],
                    quickCategories: [
                        BannerCategoryTile(title: "Fresh Eggs", subtitle: "Farm Pick", iconName: "oval.fill", filterCategory: "Meat & Eggs"),
                        BannerCategoryTile(title: "Chicken Breast", subtitle: "Skinless", iconName: "flame.fill", filterCategory: "Meat & Eggs"),
                        BannerCategoryTile(title: "Mutton Cut", subtitle: "Tender", iconName: "square.fill", filterCategory: "Meat & Eggs"),
                        BannerCategoryTile(title: "Fish Fillet", subtitle: "Fresh Catch", iconName: "drop.fill", filterCategory: "Meat & Eggs")
                    ],
                    tickerText: "Supercharge your day with 40g Protein!",
                    tickerSubtitle: "Try Chef Zest's 10-minute Egg & Chicken Scramble",
                    ctaText: "Shop Meat & Eggs"
                ),
                nonVegNightVariant: DailyThemeVariant(
                    title: "MIDNIGHT EGG & CHICKEN KEBAB NIGHT",
                    subtitle: "Late-night egg rolls, spicy chicken wings & smoky seekh kebabs.",
                    badgeText: "NIGHT MEAT FEAST • DAY 1",
                    gradientColors: [Color(red: 0.35, green: 0.10, blue: 0.15), Color(red: 0.18, green: 0.04, blue: 0.08)],
                    accentColor: Color(red: 0.98, green: 0.72, blue: 0.32),
                    promotedProducts: [
                        PromotedProduct(name: "Double Egg Roll", subtitle: "Spicy • ₹110", iconName: "takeoutbag.and.cup.and.straw.fill", emoji: "🌯", tag: "Hot & Crispy", category: "Meat & Eggs"),
                        PromotedProduct(name: "Smoky Chicken Kebabs", subtitle: "250g • ₹190", iconName: "flame.fill", emoji: "🍢", tag: "Ready in 5m", category: "Meat & Eggs")
                    ],
                    quickCategories: [
                        BannerCategoryTile(title: "Egg Rolls", subtitle: "Midnight Hot", iconName: "moon.stars.fill", filterCategory: "Meat & Eggs"),
                        BannerCategoryTile(title: "Chicken Wings", subtitle: "BBQ Sauce", iconName: "flame.fill", filterCategory: "Meat & Eggs"),
                        BannerCategoryTile(title: "Kebab Skewers", subtitle: "Smoky", iconName: "sparkles", filterCategory: "Meat & Eggs"),
                        BannerCategoryTile(title: "Cold Brew", subtitle: "Chill Drink", iconName: "cup.and.saucer.fill", filterCategory: "Pantry")
                    ],
                    tickerText: "Late Night Egg Roll & Kebab Express!",
                    tickerSubtitle: "Delivered hot to your doorstep in 15 mins",
                    ctaText: "Order Night Feast"
                )
            )

        case 2:
            return DailyTheme(
                dayNumber: 2,
                themeName: "BBQ & Grill Festival",
                vegDayVariant: DailyThemeVariant(
                    title: "TANDOORI PANEER & MUSHROOM GRILL FEST",
                    subtitle: "Juicy marinated paneer tikka, button mushrooms & bell peppers.",
                    badgeText: "BBQ FESTIVAL • DAY 2",
                    gradientColors: [Color(red: 0.85, green: 0.35, blue: 0.12), Color(red: 0.52, green: 0.18, blue: 0.06)],
                    accentColor: Color(red: 0.98, green: 0.88, blue: 0.42),
                    promotedProducts: [
                        PromotedProduct(name: "Paneer Tikka Marinated", subtitle: "250g • ₹140", iconName: "flame.fill", emoji: "🧀", tag: "Smoky BBQ", category: "Dairy"),
                        PromotedProduct(name: "Fresh Button Mushrooms", subtitle: "200g • ₹65", iconName: "leaf.fill", emoji: "🍄", tag: "Farm Pick", category: "Produce")
                    ],
                    quickCategories: [
                        BannerCategoryTile(title: "Paneer Tikka", subtitle: "Marinated", iconName: "flame.fill", filterCategory: "Dairy"),
                        BannerCategoryTile(title: "Mushrooms", subtitle: "Button Fresh", iconName: "leaf.fill", filterCategory: "Produce"),
                        BannerCategoryTile(title: "Capsicum", subtitle: "Red & Yellow", iconName: "circle.fill", filterCategory: "Produce"),
                        BannerCategoryTile(title: "Mint Chutney", subtitle: "Dip Sauce", iconName: "drop.fill", filterCategory: "Pantry")
                    ],
                    tickerText: "Master the Home Tandoori Grill!",
                    tickerSubtitle: "Get 3-ingredient Tandoori Marinade recipes",
                    ctaText: "Shop BBQ Veg"
                ),
                vegNightVariant: DailyThemeVariant(
                    title: "MIDNIGHT CHEESY PANEER SLIDERS",
                    subtitle: "Melty paneer sliders & spicy mint chutney toast for cozy late nights.",
                    badgeText: "NIGHT BITES • DAY 2",
                    gradientColors: [Color(red: 0.32, green: 0.12, blue: 0.22), Color(red: 0.16, green: 0.05, blue: 0.12)],
                    accentColor: Color(red: 0.98, green: 0.65, blue: 0.35),
                    promotedProducts: [
                        PromotedProduct(name: "Spicy Paneer Slider", subtitle: "2 Pcs • ₹120", iconName: "birthday.cake.fill", emoji: "🍔", tag: "Melted Cheese", category: "Dairy"),
                        PromotedProduct(name: "Mint Mayo Dip", subtitle: "150g • ₹50", iconName: "drop.triangle.fill", emoji: "🫙", tag: "Zesty Dip", category: "Pantry")
                    ],
                    quickCategories: [
                        BannerCategoryTile(title: "Paneer Slider", subtitle: "Cheesy", iconName: "moon.stars.fill", filterCategory: "Dairy"),
                        BannerCategoryTile(title: "Crispy Wedges", subtitle: "Spicy", iconName: "flame.fill", filterCategory: "Pantry"),
                        BannerCategoryTile(title: "Zero Soda", subtitle: "Chilled", iconName: "cup.and.saucer.fill", filterCategory: "Pantry"),
                        BannerCategoryTile(title: "Garlic Toast", subtitle: "Oven Baked", iconName: "birthday.cake.fill", filterCategory: "Bakery")
                    ],
                    tickerText: "Night Cheese & Paneer Craving Solved!",
                    tickerSubtitle: "Delivered fresh in 12 minutes",
                    ctaText: "Order Sliders"
                ),
                nonVegDayVariant: DailyThemeVariant(
                    title: "JUICY CHICKEN WINGS & MUTTON KEBABS",
                    subtitle: "Smoky tandoori wings, mutton seekh kebabs & spicy dipping chutney.",
                    badgeText: "GRILL MASTER • DAY 2",
                    gradientColors: [Color(red: 0.78, green: 0.18, blue: 0.12), Color(red: 0.45, green: 0.08, blue: 0.05)],
                    accentColor: Color(red: 0.98, green: 0.78, blue: 0.35),
                    promotedProducts: [
                        PromotedProduct(name: "Hot Chicken Wings", subtitle: "500g • ₹220", iconName: "flame.fill", emoji: "🍗", tag: "Extra Spicy", category: "Meat & Eggs"),
                        PromotedProduct(name: "Mutton Seekh Kebab", subtitle: "4 Pcs • ₹280", iconName: "sparkles", emoji: "🥩", tag: "Chef Secret", category: "Meat & Eggs")
                    ],
                    quickCategories: [
                        BannerCategoryTile(title: "BBQ Wings", subtitle: "Spicy Glaze", iconName: "flame.fill", filterCategory: "Meat & Eggs"),
                        BannerCategoryTile(title: "Mutton Seekh", subtitle: "Juicy Cuts", iconName: "square.fill", filterCategory: "Meat & Eggs"),
                        BannerCategoryTile(title: "Smoky Dip", subtitle: "Chili Mayo", iconName: "drop.fill", filterCategory: "Pantry"),
                        BannerCategoryTile(title: "Naan Bread", subtitle: "Garlic Butter", iconName: "birthday.cake.fill", filterCategory: "Bakery")
                    ],
                    tickerText: "Sizzling BBQ Grill at Home!",
                    tickerSubtitle: "Pre-marinated meats ready to pan-fry in 8 mins",
                    ctaText: "Shop BBQ Meats"
                ),
                nonVegNightVariant: DailyThemeVariant(
                    title: "MIDNIGHT TANDOORI TANGDI & BEER BITES",
                    subtitle: "Smoky chicken drumsticks & egg tandoori bowls for midnight cravings.",
                    badgeText: "NIGHT MEAT FEAST • DAY 2",
                    gradientColors: [Color(red: 0.28, green: 0.08, blue: 0.12), Color(red: 0.12, green: 0.02, blue: 0.05)],
                    accentColor: Color(red: 0.98, green: 0.62, blue: 0.28),
                    promotedProducts: [
                        PromotedProduct(name: "Tandoori Tangdi Kebabs", subtitle: "4 Pcs • ₹240", iconName: "flame.fill", emoji: "🍗", tag: "Juicy Leg", category: "Meat & Eggs"),
                        PromotedProduct(name: "Spicy Egg Roast", subtitle: "3 Eggs • ₹90", iconName: "oval.fill", emoji: "🥚", tag: "Hot Roast", category: "Meat & Eggs")
                    ],
                    quickCategories: [
                        BannerCategoryTile(title: "Chicken Tangdi", subtitle: "Smoky Leg", iconName: "flame.fill", filterCategory: "Meat & Eggs"),
                        BannerCategoryTile(title: "Egg Roast", subtitle: "Spicy Gravy", iconName: "oval.fill", filterCategory: "Meat & Eggs"),
                        BannerCategoryTile(title: "Chili Dip", subtitle: "Extra Hot", iconName: "drop.fill", filterCategory: "Pantry"),
                        BannerCategoryTile(title: "Night Drinks", subtitle: "Cold Brew", iconName: "mug.fill", filterCategory: "Pantry")
                    ],
                    tickerText: "Smoky Kebabs delivered till 3 AM!",
                    tickerSubtitle: "Get 15% off on midnight tandoori platters",
                    ctaText: "Order Kebabs"
                )
            )

        default:
            return generateGenericTheme(day: day)
        }
    }

    private static func generateGenericTheme(day: Int) -> DailyTheme {
        let vegTitles = [
            ("SOYA BOLOGNESE & CREAMY PANEER PASTA", "Durum wheat pasta with plant-based soya mince & fresh parmesan.", "ITALIAN BISTRO • DAY \(day)", [Color(red: 0.82, green: 0.28, blue: 0.15), Color(red: 0.52, green: 0.12, blue: 0.08)], Color(red: 0.98, green: 0.88, blue: 0.42), "🫘", "Soya Bolognese", "🧀", "Fresh Paneer"),
            ("HIGH-FIBER SPROUTS & TOFU GYM BOWL", "Crispy roasted chana, sprouted legumes & pan-seared organic tofu.", "FITNESS FUEL • DAY \(day)", [Color(red: 0.18, green: 0.45, blue: 0.68), Color(red: 0.08, green: 0.22, blue: 0.45)], Color(red: 0.35, green: 0.88, blue: 0.98), "🧈", "Organic Tofu", "🌱", "High-Fiber Sprouts"),
            ("SHAHI PANEER & MATAR SOYA CURRY", "Rich cashew gravy paneer & soft soya chunks cooked with fresh peas.", "ROYAL FEAST • DAY \(day)", [Color(red: 0.88, green: 0.42, blue: 0.12), Color(red: 0.58, green: 0.20, blue: 0.05)], Color(red: 0.98, green: 0.82, blue: 0.35), "🧀", "Shahi Paneer", "🫘", "Matar Soya Curry"),
            ("ASIAN STEAMED SOYA MOMOS & TOFU WOK", "Juicy vegetable soya momos & chili garlic tofu stir-fry.", "WOK & ROLL • DAY \(day)", [Color(red: 0.78, green: 0.18, blue: 0.18), Color(red: 0.48, green: 0.08, blue: 0.08)], Color(red: 0.98, green: 0.75, blue: 0.28), "🥟", "Soya Momos", "🧈", "Chili Garlic Tofu"),
            ("AVOCADO SOYA TOAST & PLANT MILK", "Creamy avocado mash, soya protein spread & fortified almond milk.", "ARTISANAL BRUNCH • DAY \(day)", [Color(red: 0.28, green: 0.58, blue: 0.32), Color(red: 0.12, green: 0.38, blue: 0.18)], Color(red: 0.95, green: 0.88, blue: 0.42), "🥑", "Avocado Mash", "🥛", "Almond Milk"),
            ("SOYA KATHI ROLL & CRISPY CORN", "Spiced soya chunk whole wheat roll & buttered golden sweet corn.", "STREET FIESTA • DAY \(day)", [Color(red: 0.85, green: 0.48, blue: 0.18), Color(red: 0.58, green: 0.28, blue: 0.08)], Color(red: 0.98, green: 0.85, blue: 0.35), "🌯", "Soya Kathi Roll", "🌽", "Sweet Corn"),
            ("CREAMY MUSHROOM & SOYA VEGGIE STEW", "Wild truffle mushroom soup & slow-simmered soya vegetable stew.", "COZY HEARTH • DAY \(day)", [Color(red: 0.52, green: 0.35, blue: 0.22), Color(red: 0.30, green: 0.18, blue: 0.10)], Color(red: 0.98, green: 0.78, blue: 0.45), "🍄", "Truffle Mushroom", "🍲", "Soya Veggie Stew"),
            ("MALAI SOYA CHAAP & TANDOORI BROCCOLI", "Smoky malai soya skewers & charred broccoli in spiced yogurt.", "TANDOORI NIGHTS • DAY \(day)", [Color(red: 0.82, green: 0.38, blue: 0.15), Color(red: 0.52, green: 0.18, blue: 0.06)], Color(red: 0.98, green: 0.85, blue: 0.32), "🍢", "Malai Soya Chaap", "🥦", "Tandoori Broccoli")
        ]

        let nonVegTitles = [
            ("CHICKEN ALFREDO & MEATBALL PASTA", "Juicy tender chicken strips & seasoned meatballs in alfredo sauce.", "ITALIAN BISTRO • DAY \(day)", [Color(red: 0.18, green: 0.25, blue: 0.58), Color(red: 0.08, green: 0.12, blue: 0.35)], Color(red: 0.42, green: 0.85, blue: 0.98), "🍗", "Chicken Alfredo", "🧆", "Beef Meatballs"),
            ("BOILED EGG WHITES & SEAFOOD SALMON", "Omega-3 enriched egg whites & pan-seared Atlantic salmon fillet.", "FITNESS FUEL • DAY \(day)", [Color(red: 0.12, green: 0.38, blue: 0.62), Color(red: 0.05, green: 0.18, blue: 0.38)], Color(red: 0.35, green: 0.88, blue: 0.98), "🥚", "Boiled Egg Whites", "🐟", "Salmon Fillet"),
            ("BUTTER CHICKEN & MUTTON ROGAN JOSH", "Rich butter chicken gravy & slow-cooked tender mutton curries.", "ROYAL FEAST • DAY \(day)", [Color(red: 0.82, green: 0.28, blue: 0.12), Color(red: 0.52, green: 0.12, blue: 0.05)], Color(red: 0.98, green: 0.78, blue: 0.32), "🍗", "Butter Chicken", "🥩", "Mutton Rogan Josh"),
            ("STEAMED CHICKEN MOMOS & BUTTER PRAWNS", "Juicy steamed chicken dumplings & spicy butter garlic jumbo prawns.", "WOK & ROLL • DAY \(day)", [Color(red: 0.78, green: 0.12, blue: 0.18), Color(red: 0.45, green: 0.05, blue: 0.08)], Color(red: 0.98, green: 0.72, blue: 0.35), "🥟", "Chicken Momos", "🦐", "Butter Prawns"),
            ("SMOKED TURKEY SLICES & FLUFFY EGGS", "Lean turkey bacon slices & fluffy 3-egg omelettes cooked in butter.", "ARTISANAL BRUNCH • DAY \(day)", [Color(red: 0.32, green: 0.22, blue: 0.48), Color(red: 0.16, green: 0.10, blue: 0.28)], Color(red: 0.98, green: 0.75, blue: 0.45), "🥓", "Smoked Turkey", "🍳", "Fluffy Omelette"),
            ("DOUBLE EGG ROLL & CHICKEN SHAWARMA", "Crispy egg roll & authentic flame-grilled chicken shawarma wraps.", "STREET FIESTA • DAY \(day)", [Color(red: 0.85, green: 0.38, blue: 0.15), Color(red: 0.55, green: 0.18, blue: 0.06)], Color(red: 0.98, green: 0.82, blue: 0.35), "🌯", "Double Egg Roll", "🥙", "Chicken Shawarma"),
            ("CHICKEN CLEAR BROTH & MUTTON STEW", "Collagen-rich chicken clear soup & slow-simmered bone broth.", "COZY HEARTH • DAY \(day)", [Color(red: 0.48, green: 0.22, blue: 0.18), Color(red: 0.25, green: 0.10, blue: 0.08)], Color(red: 0.98, green: 0.72, blue: 0.38), "🍲", "Chicken Clear Soup", "🍖", "Mutton Bone Broth"),
            ("MALAI CHICKEN TANGDI & FISH TIKKA", "Juicy cream-marinated drumsticks & coastal spiced fish tikka.", "TANDOORI NIGHTS • DAY \(day)", [Color(red: 0.82, green: 0.25, blue: 0.12), Color(red: 0.48, green: 0.10, blue: 0.05)], Color(red: 0.98, green: 0.78, blue: 0.32), "🍗", "Malai Tangdi", "🐟", "Fish Tikka")
        ]

        let idx = (day - 1) % vegTitles.count
        let v = vegTitles[idx]
        let nv = nonVegTitles[idx]

        return DailyTheme(
            dayNumber: day,
            themeName: "Day \(day) Special",
            vegDayVariant: DailyThemeVariant(
                title: v.0,
                subtitle: v.1,
                badgeText: v.2,
                gradientColors: v.3,
                accentColor: v.4,
                promotedProducts: [
                    PromotedProduct(name: v.6, subtitle: "250g • ₹120", iconName: "leaf.fill", emoji: v.5, tag: "High Protein", category: "Pantry"),
                    PromotedProduct(name: v.8, subtitle: "200g • ₹95", iconName: "drop.fill", emoji: v.7, tag: "Fresh Daily", category: "Dairy")
                ],
                quickCategories: [
                    BannerCategoryTile(title: "Soya Protein", subtitle: "52g Protein", iconName: "leaf.fill", filterCategory: "Pantry"),
                    BannerCategoryTile(title: "Paneer Cuts", subtitle: "Fresh Dairy", iconName: "drop.fill", filterCategory: "Dairy"),
                    BannerCategoryTile(title: "Mushrooms", subtitle: "Farm Fresh", iconName: "circle.fill", filterCategory: "Produce"),
                    BannerCategoryTile(title: "Tofu Cubes", subtitle: "Zero Fat", iconName: "square.grid.2x2.fill", filterCategory: "Dairy")
                ],
                tickerText: "100% Plant Protein Recipes for Day \(day)!",
                tickerSubtitle: "Explore Chef Zest's recommended zero-waste meals",
                ctaText: "Shop Veg Specials"
            ),
            vegNightVariant: DailyThemeVariant(
                title: "MIDNIGHT VEG SOYA BITES • DAY \(day)",
                subtitle: "Cozy late-night soya rolls & warm herbal teas for peaceful rest.",
                badgeText: "NIGHT RESET MODE • DAY \(day)",
                gradientColors: [Color(red: 0.12, green: 0.20, blue: 0.35), Color(red: 0.06, green: 0.10, blue: 0.20)],
                accentColor: Color(red: 0.42, green: 0.82, blue: 0.98),
                promotedProducts: [
                    PromotedProduct(name: "\(v.6) Wrap", subtitle: "Night Special • ₹110", iconName: "moon.stars.fill", emoji: v.5, tag: "10-Min Prep", category: "Pantry"),
                    PromotedProduct(name: "Warm Golden Milk", subtitle: "300ml • ₹60", iconName: "mug.fill", emoji: "🥛", tag: "Sleep Well", category: "Dairy")
                ],
                quickCategories: [
                    BannerCategoryTile(title: "Night Snacks", subtitle: "Light", iconName: "moon.stars.fill", filterCategory: "Pantry"),
                    BannerCategoryTile(title: "Herbal Tea", subtitle: "Calming", iconName: "mug.fill", filterCategory: "Pantry"),
                    BannerCategoryTile(title: "Dark Choco", subtitle: "Guilt-Free", iconName: "heart.fill", filterCategory: "Bakery"),
                    BannerCategoryTile(title: "Toasted Oats", subtitle: "High Fiber", iconName: "circle.grid.cross.fill", filterCategory: "Pantry")
                ],
                tickerText: "Late Night Soya & Paneer Snacks!",
                tickerSubtitle: "Order in 10 minutes with zero hassle",
                ctaText: "Order Late Snacks"
            ),
            nonVegDayVariant: DailyThemeVariant(
                title: nv.0,
                subtitle: nv.1,
                badgeText: nv.2,
                gradientColors: nv.3,
                accentColor: nv.4,
                promotedProducts: [
                    PromotedProduct(name: nv.6, subtitle: "500g • ₹240", iconName: "flame.fill", emoji: nv.5, tag: "30g Protein", category: "Meat & Eggs"),
                    PromotedProduct(name: nv.8, subtitle: "250g • ₹280", iconName: "square.fill", emoji: nv.7, tag: "Fresh Cut", category: "Meat & Eggs")
                ],
                quickCategories: [
                    BannerCategoryTile(title: "Fresh Eggs", subtitle: "Farm Pick", iconName: "oval.fill", filterCategory: "Meat & Eggs"),
                    BannerCategoryTile(title: "Chicken Cut", subtitle: "Skinless", iconName: "flame.fill", filterCategory: "Meat & Eggs"),
                    BannerCategoryTile(title: "Mutton Seekh", subtitle: "Juicy", iconName: "square.fill", filterCategory: "Meat & Eggs"),
                    BannerCategoryTile(title: "Fresh Fish", subtitle: "Sea Catch", iconName: "drop.fill", filterCategory: "Meat & Eggs")
                ],
                tickerText: "Supercharge your day with Eggs & Meat!",
                tickerSubtitle: "Try Chef Zest's high-protein recipes",
                ctaText: "Shop Meat & Eggs"
            ),
            nonVegNightVariant: DailyThemeVariant(
                title: "MIDNIGHT MEAT & EGG FEAST • DAY \(day)",
                subtitle: "Late-night chicken wings, egg roast & smoky kebab rolls.",
                badgeText: "NIGHT MEAT FEAST • DAY \(day)",
                gradientColors: [Color(red: 0.28, green: 0.08, blue: 0.12), Color(red: 0.12, green: 0.02, blue: 0.05)],
                accentColor: Color(red: 0.98, green: 0.65, blue: 0.28),
                promotedProducts: [
                    PromotedProduct(name: "\(nv.6) Roast", subtitle: "Night Hot • ₹190", iconName: "flame.fill", emoji: nv.5, tag: "Hot BBQ", category: "Meat & Eggs"),
                    PromotedProduct(name: "Double Egg Scramble", subtitle: "2 Eggs • ₹70", iconName: "oval.fill", emoji: "🥚", tag: "Ready Fast", category: "Meat & Eggs")
                ],
                quickCategories: [
                    BannerCategoryTile(title: "Egg Rolls", subtitle: "Hot Bite", iconName: "moon.stars.fill", filterCategory: "Meat & Eggs"),
                    BannerCategoryTile(title: "Chicken Wings", subtitle: "Spicy", iconName: "flame.fill", filterCategory: "Meat & Eggs"),
                    BannerCategoryTile(title: "Mutton Kebab", subtitle: "Smoky", iconName: "sparkles", filterCategory: "Meat & Eggs"),
                    BannerCategoryTile(title: "Cold Drinks", subtitle: "Chilled", iconName: "cup.and.saucer.fill", filterCategory: "Pantry")
                ],
                tickerText: "Late-night Meat Cravings solved in 15 mins!",
                tickerSubtitle: "Order high-protein midnight bites",
                ctaText: "Order Night Meats"
            )
        )
    }
}
