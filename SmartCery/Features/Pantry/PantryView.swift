//
//  PantryView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct PantryView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var tabRouter: TabRouter
    @EnvironmentObject private var marketViewModel: GroceryMarketViewModel

    @State private var showingAddSheet: Bool = false
    @State private var isScrolled: Bool = false
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    @State private var showingChefZest: Bool = false

    private let categories = ["All", "Dairy", "Vegetables", "Grains", "Protein", "Pantry"]

    // Quick-Add Indian Kitchen Essentials
    private let quickAddEssentials: [(name: String, cat: String, qty: String, icon: String)] = [
        ("Fresh Paneer", "Dairy", "200g", "square.fill"),
        ("Farm Tomatoes", "Vegetables", "500g", "apple.logo"),
        ("Full Cream Milk", "Dairy", "1 Liter", "cup.and.saucer.fill"),
        ("Fresh Curd (Dahi)", "Dairy", "400g", "drop.fill"),
        ("Protein Eggs", "Protein", "6 Pack", "egg.fill"),
        ("Chakki Fresh Atta", "Grains", "5 kg", "leaf.fill"),
        ("Basmati Rice", "Grains", "1 kg", "fork.knife"),
        ("Spinach (Palak)", "Vegetables", "1 Bunch", "leaf.fill"),
        ("Desi Ghee", "Dairy", "500ml", "flame.fill"),
        ("Yellow Moong Dal", "Grains", "1 kg", "circle.grid.2x2.fill")
    ]

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange
    private let cream = AppTheme.cream
    private let softCream = AppTheme.softCream
    private let elevatedSurface = AppTheme.elevatedSurface

    var body: some View {
        ZStack {
            softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Geometry Reader for Scroll Offset Tracking
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("pantryScroll")).minY
                        )
                    }
                    .frame(height: 0)

                    // 1. LIQUID GLASS PANTRY ANALYTICS HERO CARD
                    pantrySummaryHeroCard

                    // 2. SEARCH BAR & CATEGORY FILTER RIBBON
                    searchAndFilterSection

                    // 3. AI RECIPE RESCUE BANNER (If items are expiring soon)
                    if !expiringSoonItems.isEmpty {
                        aiRecipeRescueBanner
                    }

                    // 4. NEEDS ATTENTION SECTION
                    if !filteredAttentionItems.isEmpty {
                        pantrySectionHeader(title: "Needs Attention", badge: "\(filteredAttentionItems.count)", color: zestOrange)
                        VStack(spacing: 12) {
                            ForEach(filteredAttentionItems) { item in
                                liquidPantryCard(item)
                            }
                        }
                    }

                    // 5. FRESH & STOCKED SECTION
                    pantrySectionHeader(
                        title: filteredAttentionItems.isEmpty ? "All Pantry Items" : "Fresh & Stocked",
                        badge: "\(filteredFreshItems.count)",
                        color: basilGreen
                    )

                    if filteredFreshItems.isEmpty && filteredAttentionItems.isEmpty {
                        emptyStateView
                    } else {
                        VStack(spacing: 12) {
                            ForEach(filteredFreshItems) { item in
                                liquidPantryCard(item)
                            }
                        }
                    }

                    // 6. QUICK-STOCK INDIAN ESSENTIALS GRID
                    quickStockSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .coordinateSpace(name: "pantryScroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { minY in
                let scrolled = minY < -15
                if scrolled != isScrolled {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                        isScrolled = scrolled
                    }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTopBar(
                    title: "Smart Pantry",
                    subtitle: subtitleLine,
                    trailingIcon: "plus",
                    badgeCount: store.pantry.count,
                    onTrailingTap: {
                        HapticManager.impact(.medium)
                        showingAddSheet = true
                    },
                    isScrolled: isScrolled
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingAddSheet) {
            PantrySeedView(mode: .addItems)
                .environmentObject(router)
                .environmentObject(store)
        }
        .sheet(isPresented: $showingChefZest) {
            ChefZestView()
                .environmentObject(store)
                .environmentObject(tabRouter)
        }
    }

    // MARK: - Filtered Collections
    private var allFilteredItems: [PantryItem] {
        store.pantry.filter { item in
            let matchesCategory = selectedCategory == "All" || item.category.lowercased().contains(selectedCategory.lowercased())
            let matchesSearch = searchText.isEmpty || item.name.lowercased().contains(searchText.lowercased())
            return matchesCategory && matchesSearch
        }
    }

    private var filteredAttentionItems: [PantryItem] {
        allFilteredItems.filter { item in
            if case .fresh = Expirychecker.status(for: item.expiryDate) { return false }
            return true
        }
    }

    private var filteredFreshItems: [PantryItem] {
        allFilteredItems.filter { item in
            if case .fresh = Expirychecker.status(for: item.expiryDate) { return true }
            return false
        }
    }

    private var expiringSoonItems: [PantryItem] {
        store.pantry.filter { item in
            if case .expiringSoon = Expirychecker.status(for: item.expiryDate) { return true }
            return false
        }
    }

    private var subtitleLine: String {
        let attentionCount = store.pantry.filter { if case .fresh = Expirychecker.status(for: $0.expiryDate) { return false }; return true }.count
        return attentionCount == 0 ? "\(store.pantry.count) items stocked" : "\(store.pantry.count) items • \(attentionCount) need attention"
    }

    // MARK: - 1. PANTRY SUMMARY HERO CARD
    private var pantrySummaryHeroCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "cabinet.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(zestOrange)

                    Text("KITCHEN INVENTORY")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(basilGreen.opacity(0.7))
                        .tracking(1.0)
                }

                Text("\(store.pantry.count) Items Stocked")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(basilGreen)

                HStack(spacing: 12) {
                    summaryStatBadge(count: filteredFreshItems.count, label: "Fresh", color: .green)
                    summaryStatBadge(count: expiringSoonItems.count, label: "Expiring", color: zestOrange)
                    summaryStatBadge(count: store.pantry.filter { if case .expired = Expirychecker.status(for: $0.expiryDate) { return true }; return false }.count, label: "Expired", color: .red)
                }
            }

            Spacer(minLength: 0)

            // Add Quick Pantry Item Button
            Button {
                HapticManager.impact(.medium)
                showingAddSheet = true
            } label: {
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(basilGreen)
                            .frame(width: 44, height: 44)

                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(cream)
                    }

                    Text("Add Item")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(basilGreen)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(elevatedSurface)

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [basilGreen.opacity(0.06), zestOrange.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.8), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    private func summaryStatBadge(count: Int, label: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)

            Text("\(count) \(label)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(basilGreen)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12), in: Capsule())
    }

    // MARK: - 2. SEARCH & CATEGORY FILTER SECTION
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Liquid Search Bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(basilGreen.opacity(0.6))

                TextField("Search pantry items...", text: $searchText)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(basilGreen)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(basilGreen.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
            )

            // Category Horizontal Scroll Ribbon
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        Button {
                            HapticManager.impact(.light)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedCategory = cat
                            }
                        } label: {
                            Text(cat)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(selectedCategory == cat ? cream : basilGreen)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(
                                    selectedCategory == cat ? basilGreen : elevatedSurface,
                                    in: Capsule()
                                )
                                .shadow(color: selectedCategory == cat ? basilGreen.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - 3. AI RECIPE RESCUE BANNER
    private var aiRecipeRescueBanner: some View {
        Button {
            HapticManager.impact(.medium)
            showingChefZest = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(cream)
                        .frame(width: 40, height: 40)

                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(zestOrange)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Chef Zest Recipe Rescue")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(cream)

                        Text("AI SUGGESTION")
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(zestOrange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(cream, in: Capsule())
                    }

                    Text("Cook \(expiringSoonItems.prefix(2).map(\.name).joined(separator: " & ")) before they spoil!")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(cream.opacity(0.88))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(cream)
            }
            .padding(12)
            .background(
                LinearGradient(
                    colors: [basilGreen, Color(red: 0.10, green: 0.40, blue: 0.22)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .shadow(color: basilGreen.opacity(0.25), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 4. SECTION HEADER
    private func pantrySectionHeader(title: String, badge: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(basilGreen)

            Text(badge)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(cream)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(color, in: Capsule())

            Spacer()
        }
        .padding(.top, 6)
    }

    // MARK: - 5. iOS 27 LIQUID GLASS PANTRY ITEM CARD
    private func liquidPantryCard(_ item: PantryItem) -> some View {
        let status = Expirychecker.status(for: item.expiryDate)

        return VStack(spacing: 10) {
            HStack(spacing: 12) {
                // Category Icon Capsule
                ZStack {
                    Circle()
                        .fill(cream)
                        .frame(width: 44, height: 44)

                    Image(systemName: item.iconName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(zestOrange)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(basilGreen)

                    HStack(spacing: 8) {
                        Text(item.quantity)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(basilGreen.opacity(0.65))

                        Text("•")
                            .font(.system(size: 10))
                            .foregroundStyle(basilGreen.opacity(0.3))

                        Text(item.category)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(zestOrange)
                    }
                }

                Spacer(minLength: 0)

                // Status Badge
                statusBadge(status)
            }

            // Freshness Progress Bar / Meter
            freshnessMeter(for: item.expiryDate)

            // Action Ribbon Buttons
            HStack(spacing: 10) {
                // Extend Expiry +3 Days
                Button {
                    HapticManager.impact(.light)
                    store.extendPantryItem(item.id, by: 3)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.arrow.2.circlepath")
                            .font(.system(size: 11, weight: .bold))

                        Text("+3 Days")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(basilGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(cream, in: Capsule())
                }
                .buttonStyle(.plain)

                // Add to Grocery List
                Button {
                    HapticManager.impact(.light)
                    store.addGroceryItem(name: item.name, quantity: item.quantity)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 11, weight: .bold))

                        Text("Buy Again")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(zestOrange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(zestOrange.opacity(0.12), in: Capsule())
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                // Delete Item
                Button {
                    HapticManager.impact(.medium)
                    withAnimation {
                        store.removePantryItem(item.id)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.red.opacity(0.7))
                        .padding(6)
                        .background(Color.red.opacity(0.08), in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(elevatedSurface)

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.5))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.9), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }

    // MARK: - Freshness Progress Meter
    private func freshnessMeter(for date: Date?) -> some View {
        let (ratio, color, text) = freshnessDetails(for: date)

        return VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(text)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(color)

                Spacer()

                Text("\(Int(ratio * 100))% Fresh")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen.opacity(0.5))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(basilGreen.opacity(0.1))
                        .frame(height: 5)

                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * ratio, height: 5)
                }
            }
            .frame(height: 5)
        }
    }

    private func freshnessDetails(for date: Date?) -> (ratio: CGFloat, color: Color, text: String) {
        guard let date else { return (1.0, .green, "Shelf Stable • No Expiry") }

        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if daysLeft < 0 {
            return (0.05, .red, "Expired")
        } else if daysLeft == 0 {
            return (0.15, zestOrange, "Expires Today")
        } else if daysLeft <= 3 {
            let ratio = CGFloat(daysLeft) / 7.0
            return (max(0.2, ratio), zestOrange, "\(daysLeft) Day\(daysLeft == 1 ? "" : "s") Left")
        } else {
            let ratio = min(1.0, CGFloat(daysLeft) / 14.0)
            return (ratio, .green, "\(daysLeft) Days Shelf Life")
        }
    }

    private func statusBadge(_ status: ExpiryStatus) -> some View {
        let text: String
        let color: Color

        switch status {
        case .expired:
            text = "Expired"
            color = .red
        case .expiringSoon(let daysLeft):
            text = daysLeft == 0 ? "Today" : "\(daysLeft)d left"
            color = zestOrange
        case .fresh:
            text = "Fresh"
            color = .green
        }

        return Text(text)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12), in: Capsule())
    }

    // MARK: - 6. QUICK-STOCK INDIAN ESSENTIALS SECTION
    private var quickStockSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(zestOrange)

                Text("Quick-Stock Indian Essentials")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen)

                Spacer()

                Text("Tap + to add")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(basilGreen.opacity(0.6))
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(quickAddEssentials, id: \.name) { item in
                    Button {
                        HapticManager.impact(.light)
                        let newItem = PantryItem(
                            name: item.name,
                            category: item.cat,
                            quantity: item.qty,
                            expiryDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                            iconName: item.icon
                        )
                        store.addPantryItems([newItem])
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: item.icon)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(zestOrange)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(basilGreen)
                                    .lineLimit(1)

                                Text(item.qty)
                                    .font(.system(size: 10, weight: .regular))
                                    .foregroundStyle(basilGreen.opacity(0.6))
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(basilGreen)
                        }
                        .padding(10)
                        .background(cream, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - EMPTY STATE
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(cream)
                    .frame(width: 72, height: 72)

                Image(systemName: "cabinet.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(zestOrange)
            }

            VStack(spacing: 4) {
                Text("No Pantry Items Found")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen)

                Text("Try adjusting your search filter or tap any essential below to quickly stock your pantry!")
                    .font(.system(size: 12, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(basilGreen.opacity(0.7))
                    .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    PantryView()
        .environmentObject(AppRouter())
        .environmentObject(AppStore())
        .environmentObject(TabRouter())
        .environmentObject(GroceryMarketViewModel())
}
