//
//  MarketItemImageView.swift
//  SmartCery
//
//  Created by Antigravity on 18/09/26.
//

import SwiftUI

struct MarketVegBadge: View {
    let dietType: MarketItemDiet

    init(dietType: MarketItemDiet) {
        self.dietType = dietType
    }

    init(isVegetarian: Bool) {
        self.dietType = isVegetarian ? .pureVeg : .nonVeg
    }

    var body: some View {
        let borderColor: Color = {
            switch dietType {
            case .pureVeg: return Color(red: 0.15, green: 0.65, blue: 0.25)
            case .egg: return Color(red: 0.85, green: 0.60, blue: 0.10)
            case .nonVeg: return Color(red: 0.75, green: 0.20, blue: 0.20)
            }
        }()

        let dotColor: Color = borderColor

        ZStack {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .stroke(borderColor, lineWidth: 1.2)
                .frame(width: 13, height: 13)

            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
        }
        .padding(3)
        .background(Color.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

struct MarketItemImageView: View {
    let item: MarketItem
    var contentMode: ContentMode = .fill
    var cornerRadius: CGFloat = 16

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange

    var body: some View {
        ZStack {
            // Check for local asset first (if user puts local photo in Assets.xcassets)
            if let localImage = UIImage(named: item.name) ?? UIImage(named: item.name.replacingOccurrences(of: " ", with: "_").lowercased()) {
                Image(uiImage: localImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if let urlString = item.imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Color(red: 0.94, green: 0.95, blue: 0.93)
                            ProgressView()
                                .tint(basilGreen.opacity(0.6))
                                .scaleEffect(0.8)
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                    case .failure:
                        fallbackSymbolView
                    @unknown default:
                        fallbackSymbolView
                    }
                }
            } else {
                fallbackSymbolView
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var fallbackSymbolView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.96, blue: 0.94),
                    Color(red: 0.90, green: 0.93, blue: 0.88)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: item.iconName)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(zestOrange.opacity(0.85))
        }
    }
}
