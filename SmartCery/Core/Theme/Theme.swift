//
//  Theme.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI
import UIKit

// MARK: - Central Design System Tokens
enum AppTheme {
    // MARK: - Semantic Adaptive Backgrounds (Dark Cream / Warm Organic Light & Deep Organic Dark)
    // Light: Dark cream / warm ivory #E8E1D2; Dark: Deep green-black #0D1510
    static let background = Color.dynamic(light: "E8E1D2", dark: "0D1510")

    // Light: Secondary warm background #DED6C5; Dark: #131E17
    static let secondaryBackground = Color.dynamic(light: "DED6C5", dark: "131E17")

    // Light: Card surface #E4DDCE; Dark: #19261E
    static let cardSurface = Color.dynamic(light: "E4DDCE", dark: "19261E")
    static let surface = Color.dynamic(light: "E4DDCE", dark: "19261E")

    // Light: Elevated surface #F0EADF; Dark: #203127
    static let elevatedSurface = Color.dynamic(light: "F0EADF", dark: "203127")

    // MARK: - Semantic Brand & Interaction Colors
    // Primary Green (Light: #315C43; Dark: #7EAD8A)
    static let primary = Color.dynamic(light: "315C43", dark: "7EAD8A")

    // Sage & Secondary Accents (Light: #708C70; Dark: #8FB89A)
    static let secondary = Color.dynamic(light: "708C70", dark: "8FB89A")
    static let sage = Color.dynamic(light: "708C70", dark: "8FB89A")
    static let mutedOlive = Color.dynamic(light: "7E8461", dark: "9AA07D")

    // Warm Gold & Terracotta Accents
    static let warmGold = Color.dynamic(light: "C6A45D", dark: "D5B66A")
    static let warmAccent = Color.dynamic(light: "C6A45D", dark: "D5B66A")
    static let terracotta = Color.dynamic(light: "B86F55", dark: "C27B61")

    // Background Tint Accent
    static let softTint = Color.dynamic(light: "DDD6C5", dark: "18261E")
    static let deepBasil = Color.dynamic(light: "1F432E", dark: "0B130E")
    static let freshGreen = Color.dynamic(light: "315C43", dark: "7EAD8A")

    // MARK: - Semantic Text Colors
    // Light: Dark Charcoal #252820; Dark: Warm Off-White #F0ECE1
    static let textPrimary = Color.dynamic(light: "252820", dark: "F0ECE1")
    // Light: Muted Olive-Grey #686A61; Dark: Soft Sage-Grey #A9AEA5
    static let textSecondary = Color.dynamic(light: "686A61", dark: "A9AEA5")
    static let textOnDark = Color(hex: "F0ECE1")

    // MARK: - Semantic Borders
    static let borderSubtle = Color.dynamic(light: "252820", dark: "F0ECE1").opacity(0.08)

    // MARK: - Legacy Compatibility Tokens
    static let basilGreen = primary
    static let zestOrange = terracotta
    static let cream = elevatedSurface
    static let softCream = background
    static let charcoal = textPrimary

    static func subtleShadow() -> some View {
        EmptyView()
    }
}

// MARK: - Spacing System (8pt Grid)
enum AppSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

// MARK: - Elevation & Layering System
enum AppElevation {
    static let level1 = Color.black.opacity(0.04)
    static let level2 = Color.black.opacity(0.08)
    static let level3 = Color.black.opacity(0.14)

    static let radius1: CGFloat = 4
    static let radius2: CGFloat = 8
    static let radius3: CGFloat = 16
}

// MARK: - Corner Radii System
enum AppRadius {
    static let small: CGFloat = 10
    static let medium: CGFloat = 16
    static let large: CGFloat = 22
    static let xlarge: CGFloat = 28
    static let pill: CGFloat = 999
}

// MARK: - Modern iOS Liquid Glass Material System
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat = AppRadius.large
    var isPill: Bool = false

    func body(content: Content) -> some View {
        content
            .background {
                if isPill {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.40),
                                            Color.white.opacity(0.12),
                                            Color.black.opacity(0.04)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.0
                                )
                        )
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.40),
                                            Color.white.opacity(0.12),
                                            Color.black.opacity(0.04)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.0
                                )
                        )
                }
            }
            .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 7)
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = AppRadius.large, isPill: Bool = false) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius, isPill: isPill))
    }
}

// MARK: - Dynamic Color Support for Adaptive Light/Dark Theming
extension Color {
    static func dynamic(light: String, dark: String) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark))
                : UIColor(Color(hex: light))
        })
    }

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
