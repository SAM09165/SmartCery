//
//  SmartCeryProductCard.swift
//  SmartCery
//
//  Unified, consistent product card component used across:
//  - Grocery Market (grid & horizontal carousels)
//  - Home Dashboard (deals & recommendations)
//  - Dynamic Promo Banners
//

import SwiftUI

enum ProductCardLayout {
    case vertical
    case compactHorizontal
}

struct SmartCeryProductCard: View {
    let title: String
    let unit: String
    let price: Double
    var originalPrice: Double? = nil
    var discountText: String? = nil
    var rating: Double = 4.8
    var reviewCount: Int = 120
    var iconName: String = "basket.fill"
    var imageURL: String? = nil
    var dietType: MarketItemDiet = .pureVeg
    var deliveryEstimate: String = "10m"
    var isLowStock: Bool = false
    var stockCount: Int = 15
    var quantity: Int = 0
    var isFavorite: Bool = false
    var layout: ProductCardLayout = .vertical

    var onSelect: (() -> Void)? = nil
    var onAdd: (() -> Void)? = nil
    var onIncrement: (() -> Void)? = nil
    var onDecrement: (() -> Void)? = nil
    var onToggleFavorite: (() -> Void)? = nil

    var body: some View {
        switch layout {
        case .vertical:
            verticalCard
        case .compactHorizontal:
            horizontalCard
        }
    }

    // MARK: - VERTICAL CARD (GRID & CAROUSELS)
    private var verticalCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 1. Image Showcase Container (Fixed 115pt height)
            ZStack(alignment: .topTrailing) {
                imageContainer
                    .frame(height: 115)
                    .frame(maxWidth: .infinity)
                    .clipped()

                // Top Floating Badges
                HStack(alignment: .top) {
                    // Express 10m Badge
                    HStack(spacing: 3) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 8, weight: .bold))
                        Text(deliveryEstimate)
                            .font(.system(size: 9, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(AppTheme.terracotta)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(AppTheme.elevatedSurface.opacity(0.95), in: Capsule())
                    .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)

                    Spacer(minLength: 0)

                    // Favorite Button
                    if onToggleFavorite != nil {
                        Button {
                            HapticManager.impact(.light)
                            onToggleFavorite?()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(isFavorite ? Color.red : AppTheme.textSecondary)
                                .padding(5)
                                .background(AppTheme.elevatedSurface.opacity(0.92), in: Circle())
                        }
                        .buttonStyle(.plain)
                    }

                    // Strict Veg / Non-Veg Indicator
                    dietIndicatorBadge
                }
                .padding(6)

                // Low Stock Badge
                if isLowStock {
                    VStack {
                        Spacer()
                        HStack {
                            Text("Only \(stockCount) left")
                                .font(.system(size: 8, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.85), in: Capsule())
                            Spacer()
                        }
                        .padding(6)
                    }
                }
            }
            .frame(height: 115)
            .background(AppTheme.secondaryBackground, in: RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))

            // 2. Title & Pack Info (Consistent fixed heights)
            Button {
                onSelect?()
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(height: 34, alignment: .topLeading)

                    Text(unit)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)
                        .frame(height: 16, alignment: .leading)
                }
            }
            .buttonStyle(.plain)

            // 3. Rating Row (Fixed 18pt height)
            HStack(spacing: 3) {
                Image(systemName: "star.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppTheme.warmGold)

                Text(String(format: "%.1f", rating))
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("(\(reviewCount))")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)

                Spacer(minLength: 0)

                if let discount = discountText {
                    Text(discount)
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.terracotta)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(AppTheme.terracotta.opacity(0.14), in: Capsule())
                }
            }
            .frame(height: 18)

            // 4. Price & Stepper Row (Fixed 32pt height)
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(formatPrice(price))
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.primary)

                    if let orig = originalPrice, orig > price {
                        Text(formatPrice(orig))
                            .font(.system(size: 10, weight: .medium))
                            .strikethrough()
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }

                Spacer(minLength: 0)

                addOrStepperButton
            }
            .frame(height: 32)
        }
        .padding(10)
        .background(AppTheme.cardSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .stroke(AppTheme.borderSubtle.opacity(0.8), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // MARK: - COMPACT HORIZONTAL CARD
    private var horizontalCard: some View {
        HStack(spacing: 12) {
            imageContainer
                .frame(width: 72, height: 72)
                .background(AppTheme.secondaryBackground, in: RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
                .clipped()

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    dietIndicatorBadge

                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                }

                Text(unit)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)

                HStack(spacing: 6) {
                    Text(formatPrice(price))
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.primary)

                    if let orig = originalPrice, orig > price {
                        Text(formatPrice(orig))
                            .font(.system(size: 10, weight: .medium))
                            .strikethrough()
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer()

                    addOrStepperButton
                }
            }
        }
        .padding(10)
        .background(AppTheme.cardSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .stroke(AppTheme.borderSubtle.opacity(0.7), lineWidth: 1)
        )
    }

    // MARK: - IMAGE CONTAINER
    private var imageContainer: some View {
        Group {
            if let imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        fallbackIcon
                    @unknown default:
                        fallbackIcon
                    }
                }
            } else {
                fallbackIcon
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
    }

    private var fallbackIcon: some View {
        ZStack {
            AppTheme.secondaryBackground
            Image(systemName: iconName)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(AppTheme.primary.opacity(0.65))
        }
    }

    // MARK: - DIET INDICATOR (NO EMOJIS)
    private var dietIndicatorBadge: some View {
        HStack(spacing: 2) {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(dietColor, lineWidth: 1.2)
                    .frame(width: 14, height: 14)

                Circle()
                    .fill(dietColor)
                    .frame(width: 6, height: 6)
            }
        }
    }

    private var dietColor: Color {
        switch dietType {
        case .pureVeg: return Color.green
        case .egg: return AppTheme.warmGold
        case .nonVeg: return Color.red
        }
    }

    // MARK: - ADD / STEPPER BUTTON
    @ViewBuilder
    private var addOrStepperButton: some View {
        if quantity == 0 {
            Button {
                HapticManager.impact(.light)
                onAdd?()
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                    Text("ADD")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                }
                .foregroundStyle(AppTheme.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(AppTheme.elevatedSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(AppTheme.primary.opacity(0.8), lineWidth: 1.2)
                )
            }
            .buttonStyle(.plain)
        } else {
            HStack(spacing: 6) {
                Button {
                    HapticManager.impact(.light)
                    onDecrement?()
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 22, height: 22)
                        .background(AppTheme.primary, in: Circle())
                }
                .buttonStyle(.plain)

                Text("\(quantity)")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(minWidth: 16)

                Button {
                    HapticManager.impact(.light)
                    onIncrement?()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 22, height: 22)
                        .background(AppTheme.primary, in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(AppTheme.elevatedSurface, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.primary.opacity(0.4), lineWidth: 1)
            )
        }
    }

    private func formatPrice(_ amount: Double) -> String {
        return String(format: "₹%.0f", amount)
    }
}

// MARK: - Convenience Initializer for MarketItem
extension SmartCeryProductCard {
    init(
        item: MarketItem,
        quantity: Int = 0,
        isFavorite: Bool = false,
        layout: ProductCardLayout = .vertical,
        onSelect: (() -> Void)? = nil,
        onAdd: (() -> Void)? = nil,
        onIncrement: (() -> Void)? = nil,
        onDecrement: (() -> Void)? = nil,
        onToggleFavorite: (() -> Void)? = nil
    ) {
        self.init(
            title: item.title,
            unit: item.unit,
            price: item.price,
            originalPrice: item.originalPrice,
            discountText: item.discountText,
            rating: item.rating,
            reviewCount: item.reviewCount,
            iconName: item.iconName,
            imageURL: item.imageURL,
            dietType: item.dietType,
            deliveryEstimate: item.deliveryTime,
            isLowStock: item.isLowStock,
            stockCount: item.stockCount,
            quantity: quantity,
            isFavorite: isFavorite,
            layout: layout,
            onSelect: onSelect,
            onAdd: onAdd,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
            onToggleFavorite: onToggleFavorite
        )
    }
}
