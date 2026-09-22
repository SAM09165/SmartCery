//
//  DashboardView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabRouter: TabRouter
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var marketViewModel: GroceryMarketViewModel
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var mealPlannerViewModel = MealPlannerViewModel()

    @State private var showingChefZest = false
    @State private var showingExpiryTracker = false
    @State private var isScrolled = false
    @State private var addedToPlannerToast = false

    private var userProfile: UserProfile {
        store.profile ?? UserProfile()
    }

    private var firstName: String {
        let name = userProfile.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Saalim" : (name.components(separatedBy: " ").first ?? name)
    }

    var body: some View {
        GeometryReader { proxy in
            let safeAreaTop = proxy.safeAreaInsets.top
            let topBarHeight: CGFloat = 64

            ZStack(alignment: .top) {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // 1. DYNAMIC HERO MEDIA BANNER (Extends into upper safe area)
                        DynamicHeroBannerView(
                            userProfile: userProfile,
                            topSafeAreaInset: safeAreaTop,
                            topBarClearance: topBarHeight + 8,
                            onSelectCategory: { category in
                                marketViewModel.selectedCategory = category
                                tabRouter.selectedTab = .market
                            },
                            onSelectPromotion: { promo in
                                marketViewModel.selectedCategory = promo.destinationCategory
                                tabRouter.selectedTab = .market
                            }
                        )

                        // 2. VERTICAL FEED (Dark cream warm organic styling, solid cards)
                        VStack(alignment: .leading, spacing: AppSpacing.xl) {
                            // Nutrition & Macro Progress
                            todaysHealthSection

                            // Today's Planned Meals
                            todaysMealsSection

                            // Express Grocery Recommendations
                            groceryRecommendationsSection

                            // Chef Zest AI Meal Recommendation
                            personalizedRecommendationSection

                            // Kitchen Expiry Radar
                            pantryRadarSection
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.lg)
                        .padding(.bottom, 110) // Smooth clearance for floating bottom bar
                    }
                    .background(alignment: .top) {
                        GeometryReader { scrollProxy in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: scrollProxy.frame(in: .named("dashboardScroll")).minY
                            )
                        }
                        .frame(height: 0)
                    }
                }
                .ignoresSafeArea(edges: .top)
                .coordinateSpace(name: "dashboardScroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { minY in
                    let scrolled = minY < -15
                    if scrolled != isScrolled {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                            isScrolled = scrolled
                        }
                    }
                }

                // FLOATING LIQUID GLASS TOP BAR
                AppTopBar(
                    title: "\(viewModel.timeOfDay.title), \(firstName)",
                    subtitle: "\(userProfile.dietPreference.rawValue) • 10m Delivery",
                    avatarInitials: String(firstName.prefix(2)).uppercased(),
                    onAvatarTap: {
                        tabRouter.selectedTab = .settings
                    },
                    trailingIcon: "cart.fill",
                    badgeCount: marketViewModel.cartCount,
                    onTrailingTap: {
                        tabRouter.selectedTab = .market
                    },
                    isScrolled: isScrolled,
                    isDarkHeader: true
                )
                .padding(.top, max(safeAreaTop > 0 ? safeAreaTop - 4 : 8, 8))
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingChefZest) {
            ChefZestView()
        }
        .sheet(isPresented: $showingExpiryTracker) {
            ExpiryTrackerView()
        }
        .overlay(alignment: .bottom) {
            if addedToPlannerToast {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.green)
                    Text("Added to Today's Meal Plan")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.85), in: Capsule())
                .padding(.bottom, 80)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Nutrition & Health Section
    private var todaysHealthSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Label("Today's Nutrition Goals", systemImage: "heart.text.square.fill")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppTheme.terracotta)

                    Text("\(mealPlannerViewModel.dailyCalories) kcal")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.cardSurface, in: Capsule())
            }

            VStack(spacing: AppSpacing.sm) {
                let calCurrent = mealPlannerViewModel.dailyCalories
                let calTarget = mealPlannerViewModel.targetCalories
                let calPercent = min(1.0, Double(calCurrent) / Double(max(1, calTarget)))

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Calories Consumed")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)

                        Spacer()

                        Text("\(calCurrent) / \(calTarget) kcal")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.primary)
                    }

                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppTheme.cardSurface)
                                .frame(height: 8)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.primary, AppTheme.warmAccent],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(8, g.size.width * CGFloat(calPercent)), height: 8)
                        }
                    }
                    .frame(height: 8)
                }

                Divider()
                    .overlay(AppTheme.borderSubtle.opacity(0.6))

                HStack(spacing: AppSpacing.md) {
                    healthMetricTile(
                        icon: "bolt.heart.fill",
                        title: "Protein",
                        value: "\(mealPlannerViewModel.dailyProtein) / \(mealPlannerViewModel.targetProtein)g",
                        color: AppTheme.primary
                    )

                    healthMetricTile(
                        icon: "drop.fill",
                        title: "Hydration",
                        value: "2.1 / 3.0 L",
                        color: Color.teal
                    )

                    healthMetricTile(
                        icon: "leaf.fill",
                        title: "Diet Match",
                        value: userProfile.dietPreference.rawValue,
                        color: AppTheme.primary
                    )
                }
            }
            .padding(AppSpacing.md)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        }
    }

    private func healthMetricTile(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)

                Text(value)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Today's Meals Section
    private var todaysMealsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Label("Today's Meals", systemImage: "fork.knife")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Button {
                    tabRouter.selectedTab = .mealPlanner
                } label: {
                    HStack(spacing: 4) {
                        Text("View Plan")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(AppTheme.primary)
                }
                .buttonStyle(.plain)
            }

            let todayMeals = mealPlannerViewModel.selectedDay.meals

            if todayMeals.isEmpty {
                Button {
                    tabRouter.selectedTab = .mealPlanner
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(AppTheme.warmAccent)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("No Meals Planned for Today")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)

                            Text("Tap to auto-generate today's 4-meal plan with Chef Zest.")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Spacer()
                    }
                    .padding(AppSpacing.md)
                    .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                }
                .buttonStyle(.plain)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(todayMeals) { meal in
                            todayMealCard(meal)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private func todayMealCard(_ meal: PlannedMeal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RecipeImageView(
                    title: meal.title,
                    imageURL: meal.imageURL,
                    iconName: meal.iconName,
                    contentMode: .fill,
                    cornerRadius: AppRadius.medium
                )
                .frame(width: 170, height: 105)
                .clipped()

                Text(meal.type.uppercased())
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(AppTheme.primary.opacity(0.92), in: Capsule())
                    .padding(6)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(meal.title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                    .frame(height: 18, alignment: .leading)

                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 9, weight: .medium))
                        Text(meal.cookTime)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(AppTheme.textSecondary)

                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 9, weight: .medium))
                        Text("\(meal.calories) kcal")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(AppTheme.warmAccent)
                }
                .frame(height: 16)

                // Pantry Stock Status
                Group {
                    if meal.missingItems.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color.green)
                            Text("All pantry items ready")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    } else {
                        HStack(spacing: 3) {
                            Image(systemName: "cart.badge.plus")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(AppTheme.terracotta)
                            Text("Missing \(meal.missingItems.count) items")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(AppTheme.terracotta)
                        }
                    }
                }
                .frame(height: 16, alignment: .leading)
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 2)
        }
        .padding(8)
        .frame(width: 186)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - Grocery Recommendations Section
    private var groceryRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Label("Grocery Recommendations", systemImage: "bag.fill")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Button {
                    tabRouter.selectedTab = .market
                } label: {
                    HStack(spacing: 4) {
                        Text("Explore All")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(AppTheme.primary)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(marketViewModel.smartReplenishItems) { item in
                        SmartCeryProductCard(
                            item: item,
                            quantity: marketViewModel.quantity(for: item),
                            onSelect: {
                                tabRouter.selectedTab = .market
                            },
                            onAdd: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    marketViewModel.increment(item)
                                }
                            },
                            onIncrement: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    marketViewModel.increment(item)
                                }
                            },
                            onDecrement: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    marketViewModel.decrement(item)
                                }
                            }
                        )
                        .frame(width: 164)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Personalized Recommendation (Chef Zest)
    private var personalizedRecommendationSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Label("Chef Zest AI Recommendation", systemImage: "sparkles")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Button {
                    showingChefZest = true
                } label: {
                    Text("Chat AI")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.warmAccent)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.warmAccent.opacity(0.15))
                            .frame(width: 44, height: 44)

                        Image(systemName: "sparkles")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(AppTheme.warmAccent)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text("AI DIET MATCH")
                                .font(.system(size: 9, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.primary)
                                .tracking(0.6)

                            Text(userProfile.dietPreference.rawValue)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Text("Spiced Moong & Paneer Protein Bowl")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Uses 3 pantry items • 38g Protein • 15m Prep")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 10) {
                    Button {
                        HapticManager.impact(.medium)
                        mealPlannerViewModel.addMeal(
                            title: "Spiced Moong & Paneer Bowl",
                            type: "Dinner",
                            time: "7:30 PM",
                            cookTime: "15 min",
                            calories: 480,
                            protein: 38,
                            usesPantry: ["Moong Sprouts", "Malai Paneer", "Cumin"],
                            missingItems: ["Fresh Cilantro"]
                        )
                        withAnimation {
                            addedToPlannerToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                addedToPlannerToast = false
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add to Meal Plan")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppTheme.primary, in: Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        showingChefZest = true
                    } label: {
                        Text("Customize Recipe")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(AppTheme.cardSurface, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.md)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )
        }
    }

    // MARK: - Kitchen Expiry Radar Section
    private var pantryRadarSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Label("Kitchen Radar & Expiry", systemImage: "clock.badge.exclamationmark.fill")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Button {
                    showingExpiryTracker = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Track All")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(AppTheme.primary)
                }
                .buttonStyle(.plain)
            }

            Button {
                showingExpiryTracker = true
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.terracotta.opacity(0.15))
                            .frame(width: 44, height: 44)

                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(AppTheme.terracotta)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("2 Items Expiring Within 48 Hours")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Greek Yogurt & Baby Spinach need attention. Tap to generate rescue recipes.")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(AppSpacing.md)
                .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}
