import SwiftUI

struct GroceryMarketView: View {
    @EnvironmentObject var viewModel: GroceryMarketViewModel
    @EnvironmentObject var tabRouter: TabRouter

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        ZStack {
            AppTheme.softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    categoryChips
                    itemGrid
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("Market")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    tabRouter.selectedTab = .dashboard
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Grocery Market")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(AppTheme.basilGreen)

            Text(cartStatusLine)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.basilGreen.opacity(0.6))
        }
    }

    private var cartStatusLine: String {
        viewModel.cartCount == 0
            ? "Your cart is empty — Chef Zest is judging."
            : "\(viewModel.cartCount) item\(viewModel.cartCount == 1 ? "" : "s") in your cart"
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
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.cream)
                    .frame(height: 64)

                Image(systemName: item.iconName)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(AppTheme.zestOrange)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen)
                    .lineLimit(2)

                Text(String(format: "$%.2f", item.price))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.basilGreen.opacity(0.6))
            }

            stepper(for: item)
        }
        .padding(12)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
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
                    Text("Add")
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
}

#Preview {
    NavigationStack {
        GroceryMarketView()
            .environmentObject(GroceryMarketViewModel())
            .environmentObject(TabRouter())
    }
}
