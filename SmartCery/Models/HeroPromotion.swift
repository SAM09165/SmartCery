//
//  HeroPromotion.swift
//  SmartCery
//
//  Data-driven dynamic promotional model for Home hero banner.
//  Supports daily rotation, dietary personalization, video backgrounds, and shop CTAs.
//

import Foundation
import SwiftUI

enum PromotionCategory: String, Codable, CaseIterable {
    case general = "general"
    case vegetarian = "vegetarian"
    case vegan = "vegan"
    case egg = "egg"
    case nonVegetarian = "nonVegetarian"

    var badgeText: String {
        switch self {
        case .general: return "FEATURED"
        case .vegetarian: return "100% VEG"
        case .vegan: return "PLANT-BASED"
        case .egg: return "PROTEIN RICH"
        case .nonVegetarian: return "FRESH CUTS"
        }
    }

    var badgeIcon: String {
        switch self {
        case .general: return "sparkles"
        case .vegetarian: return "leaf.fill"
        case .vegan: return "leaf.circle.fill"
        case .egg: return "oval.portrait.fill"
        case .nonVegetarian: return "fork.knife.circle.fill"
        }
    }
}

struct HeroPromotion: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var subtitle: String
    var ctaText: String
    var badgeText: String
    var badgeIcon: String
    var videoURL: URL?
    var localVideoName: String?
    var posterImage: String?
    var imageFallback: String
    var startDate: Date?
    var endDate: Date?
    var priority: Int
    var category: PromotionCategory
    var destinationCategory: String
    var isActive: Bool
    var accentColorHex: String
    var bgGradientColorsHex: [String]

    init(
        id: String,
        title: String,
        subtitle: String,
        ctaText: String,
        badgeText: String? = nil,
        badgeIcon: String? = nil,
        videoURL: URL? = nil,
        localVideoName: String? = nil,
        posterImage: String? = nil,
        imageFallback: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        priority: Int = 100,
        category: PromotionCategory = .general,
        destinationCategory: String = "All",
        isActive: Bool = true,
        accentColorHex: String = "#E5B96B",
        bgGradientColorsHex: [String] = ["#143E2B", "#1F6B45", "#0F281C"]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.ctaText = ctaText
        self.badgeText = badgeText ?? category.badgeText
        self.badgeIcon = badgeIcon ?? category.badgeIcon
        self.videoURL = videoURL
        self.localVideoName = localVideoName
        self.posterImage = posterImage
        self.imageFallback = imageFallback
        self.startDate = startDate
        self.endDate = endDate
        self.priority = priority
        self.category = category
        self.destinationCategory = destinationCategory
        self.isActive = isActive
        self.accentColorHex = accentColorHex
        self.bgGradientColorsHex = bgGradientColorsHex
    }

    var accentColor: Color {
        Color(hex: accentColorHex)
    }

    var backgroundGradient: LinearGradient {
        let colors = bgGradientColorsHex.map { Color(hex: $0) }
        return LinearGradient(
            colors: colors.isEmpty ? [Color(hex: "#1F6B45"), Color(hex: "#0F281C")] : colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Daily Rotation & Personalization Catalog
enum HeroPromotionCatalog {

    // Remote video URLs for future video playback (e.g. Firebase Storage CDN)
    private static let produceVideoURL: URL? = nil
    private static let cookingVideoURL: URL? = nil
    private static let breakfastVideoURL: URL? = nil

    static let allPromotions: [HeroPromotion] = [
        // 1. Monday — Fresh Produce
        HeroPromotion(
            id: "monday-fresh-produce",
            title: "Fresh Fruits & Vegetables",
            subtitle: "Crisp organic produce harvested today and delivered in 10 minutes",
            ctaText: "Shop Fresh",
            badgeText: "TODAY'S HARVEST",
            badgeIcon: "leaf.fill",
            videoURL: produceVideoURL,
            localVideoName: "fresh_produce_loop",
            posterImage: "hero_fresh_produce",
            imageFallback: "hero_fresh_produce",
            priority: 100,
            category: .general,
            destinationCategory: "Vegetables",
            accentColorHex: "#E5B96B",
            bgGradientColorsHex: ["#143E2B", "#1F6B45", "#0E2419"]
        ),

        // 2. Tuesday — Protein Essentials (Dietary variants)
        HeroPromotion(
            id: "tuesday-protein-veg",
            title: "Plant Protein & Dairy",
            subtitle: "Fresh malai paneer, tofu & high-protein Greek yogurts for muscle recovery",
            ctaText: "Shop Protein",
            badgeText: "HIGH PROTEIN",
            badgeIcon: "bolt.heart.fill",
            videoURL: cookingVideoURL,
            localVideoName: "protein_cooking_loop",
            posterImage: "hero_protein_essentials",
            imageFallback: "hero_protein_essentials",
            priority: 95,
            category: .vegetarian,
            destinationCategory: "Dairy & Eggs",
            accentColorHex: "#68D391",
            bgGradientColorsHex: ["#1C4532", "#22543D", "#1A202C"]
        ),
        HeroPromotion(
            id: "tuesday-protein-nonveg",
            title: "Protein Powerhouse",
            subtitle: "Fresh farm eggs, tender cuts & wholesome meals delivered chilled",
            ctaText: "Shop Protein",
            badgeText: "FRESH CUTS",
            badgeIcon: "bolt.fill",
            videoURL: cookingVideoURL,
            localVideoName: "protein_cooking_loop",
            posterImage: "hero_protein_essentials",
            imageFallback: "hero_protein_essentials",
            priority: 95,
            category: .nonVegetarian,
            destinationCategory: "Dairy & Eggs",
            accentColorHex: "#F6AD55",
            bgGradientColorsHex: ["#3D1B1B", "#632727", "#1A202C"]
        ),
        HeroPromotion(
            id: "tuesday-protein-vegan",
            title: "100% Plant-Based Protein",
            subtitle: "Organic firm tofu, edamame, almond milk & sprouted legumes",
            ctaText: "Shop Vegan",
            badgeText: "PURE VEGAN",
            badgeIcon: "leaf.circle.fill",
            videoURL: cookingVideoURL,
            localVideoName: "protein_cooking_loop",
            posterImage: "hero_protein_essentials",
            imageFallback: "hero_protein_essentials",
            priority: 95,
            category: .vegan,
            destinationCategory: "Vegetables",
            accentColorHex: "#48BB78",
            bgGradientColorsHex: ["#1A365D", "#1F6B45", "#171923"]
        ),

        // 3. Wednesday — Healthy Breakfast
        HeroPromotion(
            id: "wednesday-healthy-breakfast",
            title: "Healthy Morning Fuel",
            subtitle: "Whole grain oats, stone-ground flours, berries & natural honey",
            ctaText: "Explore Breakfast",
            badgeText: "MORNING RITUAL",
            badgeIcon: "sun.max.fill",
            videoURL: breakfastVideoURL,
            localVideoName: "breakfast_loop",
            posterImage: "hero_healthy_breakfast",
            imageFallback: "hero_healthy_breakfast",
            priority: 90,
            category: .general,
            destinationCategory: "Grains",
            accentColorHex: "#ECC94B",
            bgGradientColorsHex: ["#744210", "#975A16", "#1A202C"]
        ),

        // 4. Thursday — Healthy Snacks
        HeroPromotion(
            id: "thursday-healthy-snacks",
            title: "Better Snacks & Cravings",
            subtitle: "Roasted makhana, artisanal nuts, baked crisps & antioxidant dry fruits",
            ctaText: "Shop Snacks",
            badgeText: "CLEAN CRUNCH",
            badgeIcon: "sparkles",
            videoURL: produceVideoURL,
            localVideoName: "snacks_loop",
            posterImage: "hero_healthy_snacks",
            imageFallback: "hero_healthy_snacks",
            priority: 85,
            category: .general,
            destinationCategory: "Snacks",
            accentColorHex: "#F6E05E",
            bgGradientColorsHex: ["#44337A", "#553C9A", "#1A202C"]
        ),

        // 5. Friday — Weekly Grocery Deals
        HeroPromotion(
            id: "friday-grocery-deals",
            title: "Weekly Grocery Specials",
            subtitle: "Save up to 40% on pantry staples, cold-pressed oils & fresh cartons",
            ctaText: "View Deals",
            badgeText: "LIMITED DEALS",
            badgeIcon: "tag.fill",
            videoURL: cookingVideoURL,
            localVideoName: "deals_loop",
            posterImage: "hero_grocery_deals",
            imageFallback: "hero_grocery_deals",
            priority: 80,
            category: .general,
            destinationCategory: "All",
            accentColorHex: "#F56565",
            bgGradientColorsHex: ["#7B341E", "#9C4221", "#1A202C"]
        ),

        // 6. Weekend — Family & Weekend Basket
        HeroPromotion(
            id: "weekend-family-basket",
            title: "Weekend Cooking Feast",
            subtitle: "Everything you need for cozy weekend dinners and family brunches",
            ctaText: "Shop Weekend Basket",
            badgeText: "WEEKEND SPECIAL",
            badgeIcon: "fork.knife",
            videoURL: breakfastVideoURL,
            localVideoName: "weekend_loop",
            posterImage: "hero_grocery_deals",
            imageFallback: "hero_grocery_deals",
            priority: 75,
            category: .general,
            destinationCategory: "All",
            accentColorHex: "#E5B96B",
            bgGradientColorsHex: ["#1F6B45", "#2C5282", "#1A202C"]
        )
    ]

    /// Filters and sorts active promotions based on the day of week and user's dietary preference.
    static func activePromotions(for diet: DietaryPreference, date: Date = Date()) -> [HeroPromotion] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        // 1 = Sunday, 2 = Monday, 3 = Tuesday, 4 = Wednesday, 5 = Thursday, 6 = Friday, 7 = Saturday

        let dayMatchedID: String
        switch weekday {
        case 2: // Monday
            dayMatchedID = "monday-fresh-produce"
        case 3: // Tuesday
            if diet == .vegan {
                dayMatchedID = "tuesday-protein-vegan"
            } else if diet.isStrictVeg {
                dayMatchedID = "tuesday-protein-veg"
            } else if diet == .eggitarian {
                dayMatchedID = "tuesday-protein-veg"
            } else {
                dayMatchedID = "tuesday-protein-nonveg"
            }
        case 4: // Wednesday
            dayMatchedID = "wednesday-healthy-breakfast"
        case 5: // Thursday
            dayMatchedID = "thursday-healthy-snacks"
        case 6: // Friday
            dayMatchedID = "friday-grocery-deals"
        default: // Saturday or Sunday
            dayMatchedID = "weekend-family-basket"
        }

        var results: [HeroPromotion] = []

        // Primary featured promotion of the day
        if let primary = allPromotions.first(where: { $0.id == dayMatchedID }) {
            results.append(primary)
        }

        // Secondary complementary promotions
        for promo in allPromotions {
            guard promo.id != dayMatchedID else { continue }

            if promo.category == .vegetarian && !diet.isStrictVeg && diet != .eggitarian {
                continue
            }
            if promo.category == .vegan && diet != .vegan {
                continue
            }
            if promo.category == .nonVegetarian && (diet.isStrictVeg || diet == .eggitarian || diet == .vegan) {
                continue
            }

            results.append(promo)
            if results.count >= 4 { break }
        }

        return results
    }
}
