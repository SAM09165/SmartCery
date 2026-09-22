import SwiftUI

struct GroceryMarketView: View {
    @EnvironmentObject private var store: AppStore
    @StateObject private var viewModel = GroceryMarketViewModel()

    @State private var selectedItem: MarketItem?
    @State private var showingCart = false
    @State private var showingOrderTracker = false
    @State private var isScrolled = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background.ignoresSafeArea()

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
        .onChange(of: store.profile?.dietPreference) { _, newPref in
            viewModel.syncDiet(from: newPref)
        }
        .sheet(item: $selectedItem) { item in
            ProductDetailSheet(item: item)
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showingCart) {
            MarketCartSheet()
                .environmentObject(viewModel)
                .environmentObject(store)
        }
        .sheet(isPresented: $showingOrderTracker) {
            if let order = viewModel.activeOrder {
                OrderLiveTrackerSheet(order: order)
                    .environmentObject(viewModel)
            }
        }
    }

    // MARK: - 1. EXPRESS DELIVERY HEADER BAR
    private var deliveryHeaderBar: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary)
                    .frame(width: 36, height: 36)

                Image(systemName: "bolt.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Express 10-Min Dark Store")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                }

                Text(viewModel.deliveryAddress)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if let activeOrder = viewModel.activeOrder {
                Button {
                    HapticManager.impact(.medium)
                    showingOrderTracker = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bicycle")
                            .font(.system(size: 12, weight: .bold))
                        Text("Track")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.terracotta, in: Capsule())
                    .shadow(color: AppTheme.terracotta.opacity(0.35), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(AppTheme.cardSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // MARK: - 2. DIET PREFERENCE MODE BAR
    private var dietPreferenceBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: viewModel.isVegOnlyMode ? "leaf.fill" : "fork.knife")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(viewModel.isVegOnlyMode ? Color.green : AppTheme.terracotta)

            Text(viewModel.isVegOnlyMode ? "Strict Pure-Veg Catalog Active" : "Full Catalog (Veg & Non-Veg)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Spacer()

            Toggle("", isOn: $viewModel.isVegOnlyMode)
                .labelsHidden()
                .tint(Color.green)
                .scaleEffect(0.8)
                .onChange(of: viewModel.isVegOnlyMode) { _, _ in
                    HapticManager.impact(.light)
                }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            viewModel.isVegOnlyMode ? Color.green.opacity(0.10) : AppTheme.terracotta.opacity(0.10),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(viewModel.isVegOnlyMode ? Color.green.opacity(0.3) : AppTheme.terracotta.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - 3. SEARCH BAR & CATEGORY FILTER CHIPS
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppTheme.textSecondary)

            TextField("Search fresh produce, dairy, staples...", text: $viewModel.searchText)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .liquidGlass(cornerRadius: 16)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.categories, id: \.self) { category in
                    let isSelected = category == viewModel.selectedCategory

                    Button {
                        HapticManager.impact(.light)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.selectedCategory = category
                        }
                    } label: {
                        Text(category)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(isSelected ? Color.white : AppTheme.textPrimary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                isSelected ? AppTheme.primary : AppTheme.cardSurface,
                                in: Capsule()
                            )
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? Color.clear : AppTheme.borderSubtle, lineWidth: 1)
                            )
                            .shadow(color: isSelected ? AppTheme.primary.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - 4. HERO BANNER
    private var heroBanner: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [AppTheme.primary, AppTheme.deepBasil],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .bold))
                        Text("CHEF ZEST REPLENISH")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .tracking(0.8)
                    }
                    .foregroundStyle(AppTheme.warmGold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.black.opacity(0.35), in: Capsule())

                    Text("Smart Grocery Replenishment")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)

                    Text("Auto-matched to your missing meal plan ingredients & expiring items.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.88))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Image(systemName: "basket.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.18))
                    .offset(x: 10, y: 10)
            }
            .padding(16)
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    // MARK: - 5. SMART RECIPE INGREDIENT REPLENISHMENTS
    private var smartRecommendations: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recommended For Your Meal Plan")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Text("Based on Meals")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.warmGold)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.smartReplenishItems) { item in
                        SmartCeryProductCard(
                            item: item,
                            quantity: viewModel.quantity(for: item),
                            onSelect: { selectedItem = item },
                            onAdd: {
                                HapticManager.impact(.light)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    viewModel.increment(item)
                                }
                            },
                            onIncrement: {
                                HapticManager.impact(.light)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    viewModel.increment(item)
                                }
                            },
                            onDecrement: {
                                HapticManager.impact(.light)
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    viewModel.decrement(item)
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

    // MARK: - 6. PRODUCT GRID
    private var productGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(viewModel.selectedCategory) Items (\(viewModel.filteredItems.count))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()
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
        return SmartCeryProductCard(
            item: item,
            quantity: quantity,
            onSelect: {
                selectedItem = item
            },
            onAdd: {
                HapticManager.impact(.light)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.increment(item)
                }
            },
            onIncrement: {
                HapticManager.impact(.light)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.increment(item)
                }
            },
            onDecrement: {
                HapticManager.impact(.light)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.decrement(item)
                }
            }
        )
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
                        .foregroundStyle(Color.white)

                    Text(viewModel.formatPrice(viewModel.total))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.9))
                }

                Spacer()

                HStack(spacing: 6) {
                    Text("View Cart")
                        .font(.system(size: 14, weight: .black, design: .rounded))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(AppTheme.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white, in: Capsule())
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(AppTheme.primary, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: AppTheme.primary.opacity(0.35), radius: 12, x: 0, y: 6)
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
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Large Image
                    ZStack(alignment: .topTrailing) {
                        MarketItemImageView(
                            item: item,
                            contentMode: .fill,
                            cornerRadius: 20
                        )
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .background(AppTheme.secondaryBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                        HStack(spacing: 6) {
                            Text(item.deliveryTime)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.terracotta)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.elevatedSurface.opacity(0.95), in: Capsule())
                        }
                        .padding(12)
                    }

                    // Title & Price Row
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        HStack(spacing: 10) {
                            Text(viewModel.formatPrice(item.price))
                                .font(.system(size: 22, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.primary)

                            if let original = item.originalPrice {
                                Text(viewModel.formatPrice(original))
                                    .font(.system(size: 14, weight: .medium))
                                    .strikethrough()
                                    .foregroundStyle(AppTheme.textSecondary)
                            }

                            if let discount = item.discountText {
                                Text(discount)
                                    .font(.system(size: 11, weight: .black, design: .rounded))
                                    .foregroundStyle(AppTheme.terracotta)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(AppTheme.terracotta.opacity(0.14), in: Capsule())
                            }
                        }

                        Text(item.unit)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Divider()
                        .overlay(AppTheme.borderSubtle)

                    // Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Product Details")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text(item.description)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineSpacing(3)
                    }

                    // Stock & Delivery Info
                    HStack(spacing: 12) {
                        infoBadge(icon: "bolt.fill", title: "10 Min Delivery", subtitle: "Instant fulfillment", color: AppTheme.primary)
                        infoBadge(icon: "checkmark.seal.fill", title: "Fresh Guarantee", subtitle: "100% Quality inspected", color: AppTheme.secondary)
                    }

                    Spacer(minLength: 24)

                    // Bottom Add to Cart Button
                    Button {
                        HapticManager.impact(.medium)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            viewModel.increment(item)
                        }
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "cart.badge.plus")
                                .font(.system(size: 15, weight: .bold))

                            Text("Add to Cart • \(viewModel.formatPrice(item.price))")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                        }
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.primary, in: Capsule())
                        .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
            }
            .background(AppTheme.background)
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }

    private func infoBadge(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(subtitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(AppTheme.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - CART SHEET
private struct MarketCartSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: GroceryMarketViewModel
    @EnvironmentObject private var store: AppStore

    @State private var showingConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.cartItems.isEmpty {
                    emptyCartState
                } else {
                    cartContentList
                    checkoutFooter
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Your Basket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(AppTheme.primary)
                }
            }
            .alert("Order Placed!", isPresented: $showingConfirmation) {
                Button("Track Order") {
                    dismiss()
                }
            } message: {
                Text("Your items are being packed at the nearest dark store. Delivery in 10 minutes!")
            }
        }
    }

    private var emptyCartState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(AppTheme.textSecondary)

            Text("Your Cart is Empty")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Explore 500+ fresh farm items delivered in 10 minutes.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxHeight: .infinity)
    }

    private var cartContentList: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(viewModel.cartItems, id: \.item.id) { cartItem in
                    cartItemRow(cartItem)
                }

                priceBreakdownView
            }
            .padding(16)
        }
    }

    private func cartItemRow(_ cartItem: (item: MarketItem, quantity: Int)) -> some View {
        HStack(spacing: 12) {
            MarketItemImageView(
                item: cartItem.item,
                contentMode: .fill,
                cornerRadius: 10
            )
            .frame(width: 50, height: 50)
            .clipped()

            VStack(alignment: .leading, spacing: 2) {
                Text(cartItem.item.title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                Text(cartItem.item.unit)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)

                Text(viewModel.formatPrice(cartItem.item.price * Double(cartItem.quantity)))
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.primary)
            }

            Spacer()

            HStack(spacing: 6) {
                Button {
                    HapticManager.impact(.light)
                    viewModel.decrement(cartItem.item)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 22, height: 22)
                        .background(AppTheme.primary, in: Circle())
                }
                .buttonStyle(.plain)

                Text("\(cartItem.quantity)")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(minWidth: 16)

                Button {
                    HapticManager.impact(.light)
                    viewModel.increment(cartItem.item)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 22, height: 22)
                        .background(AppTheme.primary, in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(AppTheme.cardSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var priceBreakdownView: some View {
        VStack(spacing: 8) {
            priceRow(title: "Item Total", amount: viewModel.subtotal)
            priceRow(title: "Delivery Partner Fee", amount: viewModel.deliveryFee)
            priceRow(title: "Handling Fee", amount: viewModel.handlingFee)

            Divider()
                .overlay(AppTheme.borderSubtle)

            HStack {
                Text("To Pay")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Text(viewModel.formatPrice(viewModel.total))
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.primary)
            }
        }
        .padding(14)
        .background(AppTheme.cardSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var checkoutFooter: some View {
        VStack(spacing: 4) {
            Button {
                HapticManager.impact(.heavy)
                viewModel.placeOrder()
                showingConfirmation = true
            } label: {
                HStack(spacing: 8) {
                    Text("Place 10-Min Order • \(viewModel.formatPrice(viewModel.total))")
                        .font(.system(size: 15, weight: .black, design: .rounded))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.primary, in: Capsule())
                .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(AppTheme.background)
    }

    private func priceRow(title: String, amount: Double) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)

            Spacer()

            Text(viewModel.formatPrice(amount))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
        }
    }
}


// MARK: - ORDER LIVE TRACKER SHEET
private struct OrderLiveTrackerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: GroceryMarketViewModel
    let order: MarketOrder

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Animated Delivery Status
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primary.opacity(0.15))
                            .frame(width: 72, height: 72)

                        Image(systemName: "bicycle")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(AppTheme.primary)
                    }

                    Text("Arriving in \(order.estimatedMinutesRemaining) Minutes")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Order #\(order.id.uuidString.suffix(6).uppercased()) • \(order.status)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.top, 24)

                // Order summary
                VStack(alignment: .leading, spacing: 10) {
                    Text("Delivery Address")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)

                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppTheme.primary)

                        Text(order.deliveryAddress)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(AppTheme.cardSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 20)

                Spacer()
            }
            .background(AppTheme.background)
            .navigationTitle("Live Order Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
    }
}
