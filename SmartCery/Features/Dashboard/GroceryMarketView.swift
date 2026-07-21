import SwiftUI

struct GroceryMarketView: View {
    @EnvironmentObject var viewModel: GroceryMarketViewModel
    @EnvironmentObject var tabRouter: TabRouter
    @State private var selectedItem: MarketItem?
    @State private var showingCart = false
    @FocusState private var isSearchFieldFocused: Bool

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    searchBar
                    marketHero
                    categoryChips
                    itemGrid
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, viewModel.cartCount == 0 ? 28 : 104)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTopBar(
                    title: "Market",
                    subtitle: viewModel.cartStatusLine,
                    showBack: true,
                    onBack: { tabRouter.selectedTab = .dashboard },
                    trailingIcon: "cart.fill",
                    onTrailingTap: { showingCart = true }
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea(edges: .top)
                )
            }

            if viewModel.cartCount > 0 {
                checkoutBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedItem) { item in
            ProductDetailSheet(item: item)
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showingCart) {
            CartSheet()
                .environmentObject(viewModel)
        }
        .alert("Market", isPresented: orderAlertBinding) {
            Button("Done", role: .cancel) {
                viewModel.orderPlacedMessage = nil
            }
        } message: {
            Text(viewModel.orderPlacedMessage ?? "")
        }
    }

    private var orderAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.orderPlacedMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.orderPlacedMessage = nil
                }
            }
        )
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.basilGreen.opacity(0.55))

            TextField("Search groceries, herbs, dairy...", text: $viewModel.searchText)
                .focused($isSearchFieldFocused)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.basilGreen)
                .submitLabel(.search)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen.opacity(0.35))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var marketHero: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.zestOrange)
                .frame(width: 42, height: 42)
                .background(AppTheme.cream, in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text("Shop meal-plan gaps and pantry staples.")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Every item shows price, pack size, freshness window, source, delivery estimate, and stock before you add it.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppTheme.basilGreen.opacity(0.66))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.categories, id: \.self) { category in
                    categoryChip(category)
                }
            }
        }
    }

    private func categoryChip(_ category: String) -> some View {
        let isSelected = category == viewModel.selectedCategory

        return Text(category)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(isSelected ? AppTheme.cream : AppTheme.basilGreen)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? AppTheme.zestOrange : AppTheme.cream, in: Capsule())
            .onTapGesture {
                withAnimation(.easeOut(duration: 0.2)) {
                    viewModel.selectedCategory = category
                }
            }
    }

    private var itemGrid: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(viewModel.filteredItems) { item in
                itemCard(item)
            }
        }
    }

    private func itemCard(_ item: MarketItem) -> some View {
        Button {
            selectedItem = item
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.cream)
                        .frame(height: 74)

                    Image(systemName: item.iconName)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(AppTheme.zestOrange)
                        .frame(maxWidth: .infinity, maxHeight: 74)

                    if item.isLowStock {
                        Text("Low")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AppTheme.zestOrange)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(AppTheme.zestOrange.opacity(0.12), in: Capsule())
                            .padding(8)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.unit)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(AppTheme.basilGreen.opacity(0.58))
                        .lineLimit(1)

                    Text("\(viewModel.formatPrice(item.price)) · \(item.expiryWindow)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                detailPill(iconName: "clock", text: item.deliveryEstimate)
                stepper(for: item)
            }
            .padding(12)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func detailPill(iconName: String, text: String) -> some View {
        Label(text, systemImage: iconName)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(AppTheme.basilGreen.opacity(0.66))
            .lineLimit(1)
            .minimumScaleFactor(0.78)
    }

    private func stepper(for item: MarketItem) -> some View {
        let quantity = viewModel.quantity(for: item)

        return Group {
            if quantity == 0 {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.increment(item)
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.cream)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppTheme.basilGreen, in: Capsule())
                }
                .buttonStyle(.plain)
            } else {
                HStack {
                    stepperButton(systemImage: "minus", background: AppTheme.softCream, foreground: AppTheme.basilGreen) {
                        viewModel.decrement(item)
                    }

                    Spacer()

                    Text("\(quantity)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen)

                    Spacer()

                    stepperButton(systemImage: "plus", background: AppTheme.zestOrange, foreground: AppTheme.cream) {
                        viewModel.increment(item)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
                .background(AppTheme.cream, in: Capsule())
            }
        }
    }

    private func stepperButton(systemImage: String, background: Color, foreground: Color, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(foreground)
                .frame(width: 28, height: 28)
                .background(background, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private var checkoutBar: some View {
        Button {
            showingCart = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 17, weight: .semibold))

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.cartCount) item\(viewModel.cartCount == 1 ? "" : "s") in cart")
                        .font(.system(size: 13, weight: .semibold))

                    Text("Total \(viewModel.formatPrice(viewModel.total))")
                        .font(.system(size: 12, weight: .medium))
                        .opacity(0.78)
                }

                Spacer(minLength: 0)

                Text("Checkout")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(AppTheme.cream)
            .padding(16)
            .background(AppTheme.basilGreen, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct ProductDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: GroceryMarketViewModel

    let item: MarketItem

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.softCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        productIcon
                        titleBlock
                        detailGrid
                        tagSection
                        Text(item.details)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(AppTheme.basilGreen.opacity(0.68))
                            .lineSpacing(2)
                            .padding(16)
                            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    Text(viewModel.formatPrice(item.price))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen)

                    Spacer()

                    Button {
                        viewModel.increment(item)
                    } label: {
                        Label("Add to cart", systemImage: "cart.badge.plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppTheme.cream)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(AppTheme.basilGreen, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
        }
    }

    private var productIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(AppTheme.cream)
                .frame(height: 170)

            Image(systemName: item.iconName)
                .font(.system(size: 58, weight: .bold))
                .foregroundStyle(AppTheme.zestOrange)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.name)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(AppTheme.basilGreen)

            Text("\(item.unit) · \(item.category)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.basilGreen.opacity(0.62))
        }
    }

    private var detailGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            detailTile("Price", value: viewModel.formatPrice(item.price), iconName: "tag.fill")
            detailTile("Expiry", value: item.expiryWindow, iconName: "calendar")
            detailTile("Stock", value: "\(item.stockCount) left", iconName: "shippingbox.fill")
            detailTile("Delivery", value: item.deliveryEstimate, iconName: "clock.fill")
            detailTile("Origin", value: item.origin, iconName: "mappin.and.ellipse")
        }
    }

    private func detailTile(_ title: String, value: String, iconName: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.zestOrange)

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppTheme.basilGreen.opacity(0.58))

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.basilGreen)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var tagSection: some View {
        FlowLayout(spacing: 7) {
            ForEach(item.tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.zestOrange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.zestOrange.opacity(0.11), in: Capsule())
            }
        }
    }
}

private struct CartSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: GroceryMarketViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.softCream.ignoresSafeArea()

                if viewModel.cartItems.isEmpty {
                    emptyCart
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(viewModel.cartItems, id: \.item.id) { cartLine in
                                cartRow(item: cartLine.item, quantity: cartLine.quantity)
                            }

                            totalsCard
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !viewModel.cartItems.isEmpty {
                    Button {
                        viewModel.placeOrder()
                        dismiss()
                    } label: {
                        Text("Place order · \(viewModel.formatPrice(viewModel.total))")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppTheme.cream)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.basilGreen, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                }
            }
        }
    }

    private var emptyCart: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(AppTheme.zestOrange)

            Text("Your cart is empty")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.basilGreen)
        }
    }

    private func cartRow(item: MarketItem, quantity: Int) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.iconName)
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(AppTheme.zestOrange)
                .frame(width: 40, height: 40)
                .background(AppTheme.cream, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen)

                Text("\(quantity)x \(item.unit) · \(item.expiryWindow)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(AppTheme.basilGreen.opacity(0.62))
            }

            Spacer(minLength: 0)

            Text(viewModel.formatPrice(item.price * Double(quantity)))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.basilGreen)
        }
        .padding(14)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var totalsCard: some View {
        VStack(spacing: 10) {
            totalRow("Subtotal", value: viewModel.formatPrice(viewModel.subtotal))
            totalRow("Delivery", value: viewModel.deliveryFee == 0 ? "Free" : viewModel.formatPrice(viewModel.deliveryFee))
            Divider()
            totalRow("Total", value: viewModel.formatPrice(viewModel.total), isStrong: true)
        }
        .padding(16)
        .background(AppTheme.cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func totalRow(_ title: String, value: String, isStrong: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
        .font(.system(size: isStrong ? 16 : 14, weight: isStrong ? .semibold : .medium))
        .foregroundStyle(AppTheme.basilGreen)
    }
}

private struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: spacing) {
                content
            }

            VStack(alignment: .leading, spacing: spacing) {
                content
            }
        }
    }
}

#Preview {
    NavigationStack {
        GroceryMarketView()
            .environmentObject(GroceryMarketViewModel())
            .environmentObject(TabRouter())
    }
}
