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

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange
    private let cream = AppTheme.cream
    private let softCream = AppTheme.softCream
    private let elevatedSurface = AppTheme.elevatedSurface

    private var userProfile: UserProfile {
        store.profile ?? UserProfile()
    }

    private var tonightMealTitle: String {
        mealPlannerViewModel.days.first?.meals.first(where: { $0.type.lowercased().contains("dinner") })?.title ?? "Paneer Butter Masala & Rotis"
    }

    var body: some View {
        GeometryReader { proxy in
            let safeAreaTop = proxy.safeAreaInsets.top
            let topBarHeight: CGFloat = 64
            let bannerTopPadding = max(safeAreaTop + topBarHeight + 10, 128)

            ZStack(alignment: .top) {
                softCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Full-Bleed 30-Day Blinkit Hero Banner (Stretches to Top Safe Area)
                        DailyBlinkitBannerView(
                            userProfile: userProfile,
                            cartCount: marketViewModel.cartCount,
                            topPadding: bannerTopPadding,
                            onCartTap: { tabRouter.selectedTab = .market },
                            onCategorySelect: { category in
                                marketViewModel.selectedCategory = category
                                tabRouter.selectedTab = .market
                            },
                            onTickerTap: {
                                tabRouter.selectedTab = .mealPlanner
                            },
                            onAddProductToCart: { product in
                                marketViewModel.addBundle(itemNames: [product.name])
                            }
                        )

                        // Dashboard Feed Cards
                        VStack(alignment: .leading, spacing: 20) {
                            chefCard
                            statRow

                            // Conditional Pantry Card Logic
                            if store.pantry.isEmpty {
                                pantrySetupCard
                            } else {
                                nextMealReminderCard
                            }

                            nextUpSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 28)
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

                // FLOATING APPTOPBAR CAPSULE OVERLAY ON TOP OF HERO BANNER
                AppTopBar(
                    title: "SmartCery in 10 mins",
                    subtitle: "HOME · 21 Park Street, Suite 4B",
                    trailingIcon: "cart.fill",
                    badgeCount: marketViewModel.cartCount,
                    onTrailingTap: { tabRouter.selectedTab = .market },
                    isScrolled: isScrolled,
                    isDarkHeader: true
                )
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingChefZest) {
            ChefZestView()
                .environmentObject(store)
                .environmentObject(tabRouter)
        }
        .sheet(isPresented: $showingExpiryTracker) {
            ExpiryTrackerView()
                .environmentObject(store)
        }
        .onAppear {
            viewModel.updateTimeOfDay()
        }
    }

    private var chefCard: some View {
        Button {
            HapticManager.impact(.medium)
            showingChefZest = true
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(cream)
                        .frame(width: 48, height: 48)

                    Image(systemName: "sparkles")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(zestOrange)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.timeOfDay.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(basilGreen)

                    Text(viewModel.chefLine)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(basilGreen.opacity(0.72))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(basilGreen.opacity(0.4))
            }
            .padding(18)
            .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var statRow: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Expiring Soon",
                value: "\(store.expiringSoonItems.count) Items",
                icon: "exclamationmark.triangle.fill",
                accent: zestOrange
            ) {
                showingExpiryTracker = true
            }

            statCard(
                title: "Planned Meals",
                value: "\(store.plannedMealsCount) Meals",
                icon: "calendar",
                accent: basilGreen
            ) {
                tabRouter.selectedTab = .mealPlanner
            }
        }
    }

    private func statCard(title: String, value: String, icon: String, accent: Color, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.impact(.light)
            action()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(accent)

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(basilGreen.opacity(0.35))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(basilGreen)

                    Text(title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(basilGreen.opacity(0.6))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var pantrySetupCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(zestOrange.opacity(0.14))
                        .frame(width: 42, height: 42)

                    Image(systemName: "archivebox.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(zestOrange)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Set Up Your Smart Pantry")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(basilGreen)

                    Text("Add 3-5 staples to unlock instant AI recipes & expiry tracking.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(basilGreen.opacity(0.7))
                        .lineSpacing(2)
                }
            }

            Button {
                HapticManager.impact(.medium)
                tabRouter.selectedTab = .pantry
            } label: {
                HStack {
                    Text("Quick Add Pantry Staples")
                        .font(.system(size: 13, weight: .bold))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(cream)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(basilGreen, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var nextMealReminderCard: some View {
        HStack(spacing: 14) {
            RecipeImageView(
                title: tonightMealTitle,
                iconName: "fork.knife",
                contentMode: .fill,
                cornerRadius: 12
            )
            .frame(width: 48, height: 48)
            .clipped()
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 3) {
                Text("Tonight's Dinner Plan")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(basilGreen)

                Text(tonightMealTitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(basilGreen.opacity(0.72))
            }

            Spacer(minLength: 0)

            Button {
                HapticManager.impact(.light)
                tabRouter.selectedTab = .mealPlanner
            } label: {
                Text("View")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(zestOrange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(zestOrange.opacity(0.12), in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var nextUpSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Smart Actions")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(basilGreen)

                Spacer()
            }

            VStack(spacing: 10) {
                actionRow(
                    title: "Smart Market Express",
                    subtitle: "15 min delivery for groceries & daily essentials",
                    icon: "cart.fill",
                    badge: marketViewModel.cartCount > 0 ? "\(marketViewModel.cartCount) in cart" : nil
                ) {
                    tabRouter.selectedTab = .market
                }

                actionRow(
                    title: "Expiry & Freshness Radar",
                    subtitle: "\(store.expiringSoonItems.count) items need attention this week",
                    icon: "clock.badge.exclamationmark",
                    badge: store.expiringSoonItems.isEmpty ? nil : "Action Needed"
                ) {
                    showingExpiryTracker = true
                }

                actionRow(
                    title: "Ask Chef Zest AI",
                    subtitle: "Get instant recipe ideas based on what's in your fridge",
                    icon: "sparkles",
                    badge: "AI Powered"
                ) {
                    showingChefZest = true
                }
            }
        }
    }

    private func actionRow(title: String, subtitle: String, icon: String, badge: String? = nil, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.impact(.light)
            action()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(cream)
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(zestOrange)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(basilGreen)

                        if let badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(cream)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(zestOrange, in: Capsule())
                        }
                    }

                    Text(subtitle)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(basilGreen.opacity(0.65))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(basilGreen.opacity(0.35))
            }
            .padding(12)
            .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppRouter())
        .environmentObject(TabRouter())
        .environmentObject(AppStore())
        .environmentObject(GroceryMarketViewModel())
}
