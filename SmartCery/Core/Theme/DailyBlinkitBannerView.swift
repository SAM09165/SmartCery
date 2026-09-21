//
//  DailyBlinkitBannerView.swift
//  SmartCery
//
//  Blinkit-inspired Full-Bleed 30-Day Hero Banner.
//  Stretches to the top safe area and covers controls, and main promo banner
//  down to halfway down the screen with dynamic Veg (Soya/Paneer) & Non-Veg (Egg/Meat) promotions.
//

import SwiftUI

struct DailyBlinkitBannerView: View {
    var userProfile: UserProfile = UserProfile()
    var cartCount: Int = 0
    var topPadding: CGFloat = 132
    var onCartTap: (() -> Void)? = nil
    var onCategorySelect: ((String) -> Void)? = nil
    var onTickerTap: (() -> Void)? = nil
    var onAddProductToCart: ((PromotedProduct) -> Void)? = nil

    @State private var isNightOverride: Bool? = nil
    @State private var activeDietOverride: DietaryPreference? = nil
    @State private var dayOverride: Int? = nil
    @State private var addedProductNotification: String? = nil

    private var effectiveDiet: DietaryPreference {
        activeDietOverride ?? userProfile.dietPreference
    }

    private var currentData: (variant: DailyThemeVariant, dayNumber: Int) {
        DailyThemeCatalog.currentTheme(
            dayOverride: dayOverride,
            overrideIsNight: isNightOverride,
            dietPreference: effectiveDiet
        )
    }

    private var currentVariant: DailyThemeVariant {
        currentData.variant
    }

    private var currentDay: Int {
        currentData.dayNumber
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                // Dynamic Multi-Layer Gradient Background (Extends to Top Safe Area Edge)
                bannerBackground

                VStack(spacing: 14) {
                    // 1. INTERACTIVE CONTROL RIBBON (Day Stepper, Veg/Non-Veg Toggle & Ambient Mode)
                    controlRibbon
                        .padding(.top, topPadding)

                    // 2. MAIN HERO BANNER (Blinkit Split Layout: Headline & CTA on Left, Products on Right)
                    HStack(alignment: .top, spacing: 12) {
                        // Left Column: Headline, Subtitle & Shop Now CTA
                        VStack(alignment: .leading, spacing: 10) {
                            Text(currentVariant.badgeText)
                                .font(.system(size: 10, weight: .black))
                                .foregroundStyle(currentVariant.accentColor)
                                .tracking(1.1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.35), in: Capsule())

                            Text(currentVariant.title)
                                .font(.system(size: 21, weight: .black))
                                .foregroundStyle(.white)
                                .lineSpacing(2)
                                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)

                            Text(currentVariant.subtitle)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.92))
                                .lineLimit(3)

                            Spacer(minLength: 4)

                            // Blinkit "Shop Now" Capsule Button
                            Button {
                                HapticManager.impact(.medium)
                                let targetCat = effectiveDiet.isStrictVeg ? "Pantry" : "Meat & Eggs"
                                onCategorySelect?(targetCat)
                            } label: {
                                HStack(spacing: 6) {
                                    Text(currentVariant.ctaText)
                                        .font(.system(size: 12, weight: .heavy))

                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 11, weight: .bold))
                                }
                                .foregroundStyle(Color(red: 0.15, green: 0.10, blue: 0.05))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white, in: Capsule())
                                .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Right Column: Dynamic Promoted Product Cards (Egg/Meat vs Soya/Paneer)
                        VStack(spacing: 8) {
                            ForEach(currentVariant.promotedProducts) { product in
                                promotedProductCard(product)
                            }
                        }
                        .frame(width: 148)
                    }

                    // 3. 4-TILE QUICK CATEGORY GRID
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(currentVariant.quickCategories) { tile in
                            Button {
                                HapticManager.impact(.light)
                                onCategorySelect?(tile.filterCategory)
                            } label: {
                                VStack(spacing: 4) {
                                    Text(tile.title)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // 4. BOTTOM MICRO PROMO TICKER STRIP
                    Button {
                        HapticManager.impact(.light)
                        onTickerTap?()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(currentVariant.accentColor)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(currentVariant.tickerText)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Color(red: 0.15, green: 0.10, blue: 0.05))

                                Text(currentVariant.tickerSubtitle)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.15))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.98, green: 0.94, blue: 0.82), Color(red: 0.95, green: 0.88, blue: 0.72)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 28, bottomTrailingRadius: 28))
            .shadow(color: currentVariant.gradientColors.first?.opacity(0.4) ?? .clear, radius: 14, x: 0, y: 8)

            // Added to Cart Toast Bar
            if let toast = addedProductNotification {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(toast)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white, in: Capsule())
                .shadow(radius: 6)
                .offset(y: 10)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Banner Multi-Layer Background
    private var bannerBackground: some View {
        ZStack {
            LinearGradient(
                colors: currentVariant.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [currentVariant.accentColor.opacity(0.35), Color.clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 260
            )

            RadialGradient(
                colors: [Color.black.opacity(0.40), Color.clear],
                center: .bottomTrailing,
                startRadius: 30,
                endRadius: 280
            )
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Control Ribbon
    private var controlRibbon: some View {
        HStack(spacing: 8) {
            // 30-Day Stepper Controls
            HStack(spacing: 6) {
                Button {
                    HapticManager.impact(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        let newDay = max(1, currentDay - 1)
                        dayOverride = newDay
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(Color.white.opacity(0.2), in: Circle())
                }
                .buttonStyle(.plain)

                Text("DAY \(currentDay)")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Button {
                    HapticManager.impact(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        let newDay = min(30, currentDay + 1)
                        dayOverride = newDay
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(Color.white.opacity(0.2), in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.3), in: Capsule())

            Spacer(minLength: 0)

            // Diet Toggle Quick Button
            Button {
                HapticManager.impact(.medium)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                    if effectiveDiet == .pureVeg {
                        activeDietOverride = .nonVeg
                    } else if effectiveDiet == .nonVeg {
                        activeDietOverride = .vegan
                    } else {
                        activeDietOverride = .pureVeg
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: effectiveDiet.badgeIcon)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(effectiveDiet.isStrictVeg ? Color.green : currentVariant.accentColor)

                    Text(effectiveDiet.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.3), in: Capsule())
            }
            .buttonStyle(.plain)

            // Day / Night Toggle
            Button {
                HapticManager.impact(.light)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                    let isNight = isNightOverride ?? (Calendar.current.component(.hour, from: Date()) >= 17 || Calendar.current.component(.hour, from: Date()) < 5)
                    isNightOverride = !isNight
                }
            } label: {
                Image(systemName: (isNightOverride ?? false) ? "moon.stars.fill" : "sun.max.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle((isNightOverride ?? false) ? Color.yellow : Color.orange)
                    .padding(6)
                    .background(Color.black.opacity(0.3), in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Promoted Product Card Component
    private func promotedProductCard(_ product: PromotedProduct) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 32, height: 32)

                Image(systemName: product.iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(currentVariant.accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(product.subtitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer(minLength: 0)

            // Add Button
            Button {
                HapticManager.impact(.medium)
                onAddProductToCart?(product)

                withAnimation {
                    addedProductNotification = "Added \(product.name) to cart!"
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        addedProductNotification = nil
                    }
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(Color(red: 0.15, green: 0.10, blue: 0.05))
                    .frame(width: 22, height: 22)
                    .background(Color.white, in: Circle())
                    .shadow(radius: 2)
            }
            .buttonStyle(.plain)
        }
        .padding(6)
        .background(Color.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }
}
