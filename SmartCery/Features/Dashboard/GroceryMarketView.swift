import SwiftUI

struct GroceryMarketView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var viewModel = GroceryMarketViewModel()

    @State private var selectedItem: MarketItem?
    @State private var showingCart = false
    @State private var showingOrderTracker = false
    @State private var isScrolled = false

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange
    private let cream = AppTheme.cream
    private let softCream = AppTheme.softCream
    private let elevatedSurface = AppTheme.elevatedSurface

    var body: some View {
        ZStack(alignment: .bottom) {
            softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Geometry Reader for Scroll Offset Tracking
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("marketScroll")).minY
                        )
                    }
                    .frame(height: 0)

                    // 1. EXPRESS DELIVERY RIBBON BAR
                    deliveryHeaderBar

                    // 2. DIET PREFERENCE MODE BAR (Pure Veg / All Toggle)
                    dietPreferenceBanner

                    // 3. LIQUID SEARCH BAR & CATEGORY CHIPS
                    searchBar
                    categoryChips

                    // 4. CHEF ZEST REPLENISH HERO BANNER
                    heroBanner

                    // 5. SMART RECIPE INGREDIENT REPLENISHMENT CAROUSEL
                    smartRecommendations

                    // 6. PRODUCT GRID
                    productGrid
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, viewModel.cartCount > 0 ? 100 : 32)
            }
            .coordinateSpace(name: "marketScroll")
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
                    title: "Smart Market Express",
                    subtitle: viewModel.cartStatusLine,
                    trailingIcon: "cart.fill",
                    badgeCount: viewModel.cartCount,
                    onTrailingTap: {
                        HapticManager.impact(.medium)
                        showingCart = true
                    },
                    isScrolled: isScrolled
                )
            }

            // STICKY FLOATING LIQUID GLASS CART DRAWER
            if viewModel.cartCount > 0 {
                checkoutBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.syncDiet(from: store.profile?.dietPreference)
        }
        .onChange(of: store.profile) { _, newProfile in
            viewModel.syncDiet(from: newProfile?.dietPreference)
        }
        .sheet(item: $selectedItem) { item in
            ProductDetailSheet(item: item)
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showingCart) {
            CartSheet(onOrderPlaced: {
                showingCart = false
                showingOrderTracker = true
            })
            .environmentObject(viewModel)
        }
        .sheet(isPresented: $showingOrderTracker) {
            if let order = viewModel.activeOrder {
                ActiveOrderSheet(order: order)
            }
        }
    }

    // MARK: - 1. EXPRESS DELIVERY HEADER BAR
    private var deliveryHeaderBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(zestOrange)

                Text("10 MIN EXPRESS")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(basilGreen)

                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(zestOrange.opacity(0.12), in: Capsule())

            Spacer(minLength: 0)

            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(basilGreen)

                Text(viewModel.deliveryAddress)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen.opacity(0.85))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.8), lineWidth: 1)
        )
    }

    // MARK: - 2. DIET PREFERENCE MODE BANNER
    private var dietPreferenceBanner: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(viewModel.isVegOnlyMode ? Color(red: 0.15, green: 0.65, blue: 0.25) : Color.orange, lineWidth: 1.2)
                    .frame(width: 14, height: 14)

                Circle()
                    .fill(viewModel.isVegOnlyMode ? Color(red: 0.15, green: 0.65, blue: 0.25) : Color.orange)
                    .frame(width: 6, height: 6)
            }
            .padding(3)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 4, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.isVegOnlyMode ? "100% Pure Veg Store Active" : "Showing All Catalog Items")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen)

                Text(viewModel.isVegOnlyMode ? "Strictly no eggs, chicken, or meat products shown." : "Vegetarian, egg, and meat items enabled.")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(basilGreen.opacity(0.65))
            }

            Spacer(minLength: 0)

            Button {
                HapticManager.impact(.light)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    viewModel.isVegOnlyMode.toggle()
                }
            } label: {
                Text(viewModel.isVegOnlyMode ? "Show All" : "Pure Veg")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(viewModel.isVegOnlyMode ? basilGreen : Color.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(viewModel.isVegOnlyMode ? Color.white : basilGreen, in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(basilGreen.opacity(0.2), lineWidth: viewModel.isVegOnlyMode ? 1 : 0)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            viewModel.isVegOnlyMode ? Color.green.opacity(0.08) : Color.orange.opacity(0.08),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(viewModel.isVegOnlyMode ? Color.green.opacity(0.25) : Color.orange.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - 3. SEARCH BAR & CATEGORY CHIPS
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(basilGreen.opacity(0.6))

            TextField("Search veggies, spices, milk, paneer...", text: $viewModel.searchText)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(basilGreen)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15, weight: .bold))
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
                .stroke(Color.white.opacity(0.8), lineWidth: 1)
        )
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.categories, id: \.self) { category in
                    let isSelected = category == viewModel.selectedCategory

                    Button {
                        HapticManager.impact(.light)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                            viewModel.selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.icon(for: category))
                                .font(.system(size: 11, weight: .bold))

                            Text(category)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(isSelected ? cream : basilGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(isSelected ? basilGreen : elevatedSurface, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.7), lineWidth: isSelected ? 0 : 1)
                        )
                        .shadow(color: isSelected ? basilGreen.opacity(0.25) : .clear, radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - 4. HERO REPLENISH BANNER
    private var heroBanner: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(zestOrange)

                    Text("CHEF ZEST REPLENISH")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(cream.opacity(0.85))
                        .tracking(1.0)
                }

                Text("One-Tap Missing Items Order")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(cream)

                Text("Quickly add all missing ingredients from your meal planner into your express cart.")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(cream.opacity(0.88))
                    .lineLimit(2)

                Button {
                    HapticManager.impact(.medium)
                    let missing = store.groceryList.map(\.name)
                    if !missing.isEmpty {
                        viewModel.addBundle(itemNames: missing)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 12, weight: .bold))

                        Text("Add All Missing Items")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(basilGreen)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(cream, in: Capsule())
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }

            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(cream.opacity(0.15))
                    .frame(width: 66, height: 66)

                Image(systemName: "bag.fill.badge.plus")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(zestOrange)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [basilGreen, Color(red: 0.10, green: 0.40, blue: 0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .shadow(color: basilGreen.opacity(0.25), radius: 8, x: 0, y: 4)
    }

    // MARK: - 5. SMART RECIPE RECOMMENDATIONS
    private var smartRecommendations: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Missing for your Meal Plan")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen)

                Spacer()

                Text("\(store.groceryList.count) needed")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(cream)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(zestOrange, in: Capsule())
            }

            if store.groceryList.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.green)

                    Text("Your kitchen covers all planned meals!")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(basilGreen)

                    Spacer()
                }
                .padding(12)
                .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(store.groceryList) { item in
                            if let matched = viewModel.allowedCatalogItems.first(where: { $0.name.caseInsensitiveCompare(item.name) == .orderedSame || $0.name.localizedCaseInsensitiveContains(item.name) }) {
                                recipeGapCard(matched)
                            }
                        }
                    }
                }
            }
        }
    }

    private func recipeGapCard(_ item: MarketItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                MarketItemImageView(item: item, contentMode: .fill, cornerRadius: 12)
                    .frame(width: 140, height: 95)
                    .clipped()

                MarketVegBadge(dietType: item.dietType)
                    .padding(6)
            }
            .frame(width: 140, height: 95)
            .background(Color.black.opacity(0.03), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen)
                    .lineLimit(1)

                Text(item.unit)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(basilGreen.opacity(0.6))
            }

            HStack {
                Text(viewModel.formatPrice(item.price))
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(basilGreen)

                Spacer()

                Button {
                    HapticManager.impact(.light)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.increment(item)
                    }
                } label: {
                    Text(viewModel.quantity(for: item) > 0 ? "\(viewModel.quantity(for: item)) in cart" : "+ ADD")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(viewModel.quantity(for: item) > 0 ? cream : basilGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(viewModel.quantity(for: item) > 0 ? zestOrange : cream, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(basilGreen.opacity(0.3), lineWidth: viewModel.quantity(for: item) > 0 ? 0 : 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .frame(width: 154)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.8), lineWidth: 1)
        )
    }

    // MARK: - 6. PRODUCT GRID
    private var productGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(viewModel.selectedCategory == "All" ? "Fresh Groceries" : viewModel.selectedCategory)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(basilGreen)

                Spacer()

                Text("\(viewModel.filteredItems.count) items")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen.opacity(0.6))
            }

            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(viewModel.filteredItems) { item in
                    productCard(item)
                }
            }
        }
    }

    private func productCard(_ item: MarketItem) -> some View {
        let quantity = viewModel.quantity(for: item)

        return VStack(alignment: .leading, spacing: 10) {
            Button {
                selectedItem = item
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    // 1. High-Quality Real Food Photo Container
                    ZStack(alignment: .topTrailing) {
                        MarketItemImageView(item: item, contentMode: .fill, cornerRadius: 16)
                            .frame(height: 125)
                            .clipped()

                        // Badges Overlay
                        HStack(alignment: .top) {
                            HStack(spacing: 3) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 8, weight: .bold))
                                Text("10m")
                                    .font(.system(size: 9, weight: .black, design: .rounded))
                            }
                            .foregroundStyle(zestOrange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.94), in: Capsule())
                            .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)

                            Spacer()

                            MarketVegBadge(dietType: item.dietType)
                        }
                        .padding(8)

                        if item.isLowStock {
                            VStack {
                                Spacer()
                                HStack {
                                    Text("Only \(item.stockCount) left")
                                        .font(.system(size: 9, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.red.opacity(0.88), in: Capsule())
                                    Spacer()
                                }
                                .padding(6)
                            }
                        }
                    }
                    .frame(height: 125)
                    .background(Color.black.opacity(0.03), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    // 2. Title & Pack Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(basilGreen)
                            .lineLimit(2)
                            .frame(height: 36, alignment: .topLeading)

                        Text("\(item.unit) • \(item.category)")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(basilGreen.opacity(0.6))
                    }

                    // 3. Price & Add Row
                    HStack(alignment: .center) {
                        Text(viewModel.formatPrice(item.price))
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(basilGreen)

                        Spacer()

                        if quantity == 0 {
                            Button {
                                HapticManager.impact(.light)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    viewModel.increment(item)
                                }
                            } label: {
                                HStack(spacing: 3) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 10, weight: .black))
                                    Text("ADD")
                                        .font(.system(size: 12, weight: .black, design: .rounded))
                                }
                                .foregroundStyle(basilGreen)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(basilGreen.opacity(0.85), lineWidth: 1.2)
                                )
                                .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                            }
                            .buttonStyle(.plain)
                        } else {
                            HStack(spacing: 6) {
                                Button {
                                    HapticManager.impact(.light)
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        viewModel.decrement(item)
                                    }
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundStyle(cream)
                                        .frame(width: 22, height: 22)
                                }
                                .buttonStyle(.plain)

                                Text("\(quantity)")
                                    .font(.system(size: 12, weight: .black, design: .rounded))
                                    .foregroundStyle(cream)
                                    .frame(minWidth: 14)

                                Button {
                                    HapticManager.impact(.light)
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        viewModel.increment(item)
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundStyle(cream)
                                        .frame(width: 22, height: 22)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(basilGreen, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.8), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - STICKY FLOATING LIQUID GLASS CART DRAWER
    private var checkoutBar: some View {
        Button {
            HapticManager.impact(.medium)
            showingCart = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.cartCount) Items in Cart")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(cream)

                    Text(viewModel.formatPrice(viewModel.total))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(cream.opacity(0.9))
                }

                Spacer()

                HStack(spacing: 6) {
                    Text("View Cart")
                        .font(.system(size: 14, weight: .black, design: .rounded))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(basilGreen)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(cream, in: Capsule())
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(zestOrange, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: zestOrange.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PRODUCT DETAIL SHEET
private struct ProductDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: GroceryMarketViewModel
    let item: MarketItem

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.softCream.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ZStack(alignment: .topTrailing) {
                            MarketItemImageView(item: item, contentMode: .fill, cornerRadius: 22)
                                .frame(height: 220)
                                .frame(maxWidth: .infinity)
                                .clipped()

                            MarketVegBadge(dietType: item.dietType)
                                .padding(14)
                        }
                        .frame(height: 220)
                        .background(AppTheme.cream, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                        .padding(.bottom, 4)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.name)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.basilGreen)

                            Text("\(item.unit) • \(item.category)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppTheme.basilGreen.opacity(0.6))

                            Text(viewModel.formatPrice(item.price))
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.zestOrange)
                                .padding(.top, 4)
                        }

                        Text(item.details)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(AppTheme.basilGreen.opacity(0.75))
                            .lineSpacing(2)

                        HStack(spacing: 8) {
                            ForEach(item.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.basilGreen)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(AppTheme.cream, in: Capsule())
                            }
                        }

                        Text("Freshly sourced for 10-minute express delivery to your doorstep.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.basilGreen.opacity(0.6))

                        Button {
                            HapticManager.impact(.medium)
                            viewModel.increment(item)
                            dismiss()
                        } label: {
                            Text("Add to Express Cart")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.cream)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppTheme.basilGreen, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 10)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

// MARK: - CART SHEET
private struct CartSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: GroceryMarketViewModel
    let onOrderPlaced: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.softCream.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Order Summary Header
                            HStack {
                                Text("Delivery Address")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.basilGreen)

                                Spacer()

                                Text(viewModel.deliveryAddress)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(AppTheme.zestOrange)
                                    .lineLimit(1)
                            }
                            .padding(14)
                            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                            // Cart Items List
                            VStack(spacing: 10) {
                                ForEach(viewModel.cartItems, id: \.item.id) { line in
                                    HStack(spacing: 12) {
                                        MarketItemImageView(item: line.item, contentMode: .fill, cornerRadius: 10)
                                            .frame(width: 44, height: 44)
                                            .clipped()

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(line.item.name)
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundStyle(AppTheme.basilGreen)

                                            Text(viewModel.formatPrice(line.item.price * Double(line.quantity)))
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(AppTheme.zestOrange)
                                        }

                                        Spacer()

                                        HStack(spacing: 6) {
                                            Button {
                                                viewModel.decrement(line.item)
                                            } label: {
                                                Image(systemName: "minus")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundStyle(AppTheme.basilGreen)
                                                    .frame(width: 24, height: 24)
                                                    .background(AppTheme.cream, in: Circle())
                                            }
                                            .buttonStyle(.plain)

                                            Text("\(line.quantity)")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundStyle(AppTheme.basilGreen)

                                            Button {
                                                viewModel.increment(line.item)
                                            } label: {
                                                Image(systemName: "plus")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundStyle(AppTheme.cream)
                                                    .frame(width: 24, height: 24)
                                                    .background(AppTheme.zestOrange, in: Circle())
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(12)
                                    .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                            }

                            // Promo Code Box
                            HStack(spacing: 10) {
                                TextField("Enter Promo Code (e.g. SMART20)", text: $viewModel.promoCode)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppTheme.basilGreen)

                                Button("Apply") {
                                    HapticManager.impact(.light)
                                    viewModel.applyPromo()
                                }
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.cream)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(AppTheme.basilGreen, in: Capsule())
                                .buttonStyle(.plain)
                            }
                            .padding(12)
                            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                            // Bill Breakdown
                            VStack(spacing: 8) {
                                billRow(title: "Subtotal", value: viewModel.formatPrice(viewModel.subtotal))
                                billRow(title: "Express 10-Min Delivery Fee", value: viewModel.deliveryFee == 0 ? "FREE" : viewModel.formatPrice(viewModel.deliveryFee))
                                if viewModel.discountAmount > 0 {
                                    billRow(title: "Promo Discount", value: "-\(viewModel.formatPrice(viewModel.discountAmount))", isDiscount: true)
                                }
                                Divider()
                                billRow(title: "To Pay", value: viewModel.formatPrice(viewModel.total), isBold: true)
                            }
                            .padding(14)
                            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                        .padding(20)
                    }

                    // Place Order Action Button
                    VStack {
                        Button {
                            HapticManager.impact(.heavy)
                            viewModel.placeOrder()
                            dismiss()
                            onOrderPlaced()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 16, weight: .bold))

                                Text("Place Order (\(viewModel.formatPrice(viewModel.total)))")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(AppTheme.cream)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.zestOrange, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: AppTheme.zestOrange.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                    .background(AppTheme.elevatedSurface)
                }
            }
            .navigationTitle("Express Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func billRow(title: String, value: String, isDiscount: Bool = false, isBold: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.system(size: isBold ? 14 : 12, weight: isBold ? .bold : .medium, design: .rounded))
                .foregroundStyle(AppTheme.basilGreen)

            Spacer()

            Text(value)
                .font(.system(size: isBold ? 15 : 12, weight: isBold ? .black : .bold, design: .rounded))
                .foregroundStyle(isDiscount ? Color.green : (isBold ? AppTheme.zestOrange : AppTheme.basilGreen))
        }
    }
}

// MARK: - ACTIVE ORDER TRACKER SHEET
private struct ActiveOrderSheet: View {
    @Environment(\.dismiss) private var dismiss
    let order: GroceryMarketViewModel.MarketOrder

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.softCream.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Rider Live Status Hero
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.cream)
                                    .frame(width: 70, height: 70)

                                Image(systemName: "scooter")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(AppTheme.zestOrange)
                            }

                            Text("Order #\(order.id.uuidString.prefix(6).uppercased())")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.basilGreen.opacity(0.6))

                            Text("Arriving in 9 Minutes!")
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.basilGreen)

                            Text("Your rider Rahul is on the way from Dark Store #4.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(AppTheme.basilGreen.opacity(0.7))
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                        // Stepper Steps
                        VStack(alignment: .leading, spacing: 14) {
                            orderStepRow(stepNum: 1, title: "Order Confirmed", subtitle: "Received at 10-Min Dark Store", isDone: true)
                            orderStepRow(stepNum: 2, title: "Packing Essentials", subtitle: "Checking freshness & expiry dates", isDone: true)
                            orderStepRow(stepNum: 3, title: "Out for Express Delivery", subtitle: "Rider assigned • Live GPS Active", isDone: true)
                            orderStepRow(stepNum: 4, title: "Delivered to Doorstep", subtitle: "Safe contactless delivery", isDone: false)
                        }
                        .padding(18)
                        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                        Button("Done") {
                            dismiss()
                        }
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.cream)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.basilGreen, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Live Order Tracking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func orderStepRow(stepNum: Int, title: String, subtitle: String, isDone: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isDone ? AppTheme.basilGreen : AppTheme.cream)
                    .frame(width: 28, height: 28)

                if isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.cream)
                } else {
                    Text("\(stepNum)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.basilGreen)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(isDone ? AppTheme.basilGreen : AppTheme.basilGreen.opacity(0.5))

                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.basilGreen.opacity(0.6))
            }

            Spacer()
        }
    }
}

#Preview {
    GroceryMarketView()
        .environmentObject(AppStore())
}
