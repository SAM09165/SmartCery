//
//  RecipeImageView.swift
//  SmartCery
//
//  Created by Antigravity on 18/09/26.
//

import SwiftUI

enum RecipeImageCatalog {
    static func imageURL(for title: String) -> String? {
        let lower = title.lowercased()

        if lower.contains("paneer") || lower.contains("palak") {
            return "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=800&q=80"
        } else if lower.contains("chickpea") || lower.contains("chana") || lower.contains("curry") {
            return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80"
        } else if lower.contains("soup") || lower.contains("dal") || lower.contains("lentil") {
            return "https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80"
        } else if lower.contains("oat") || lower.contains("parfait") || lower.contains("berry") || lower.contains("fruit") {
            return "https://images.unsplash.com/photo-1511690656952-34342bb7c2f2?auto=format&fit=crop&w=800&q=80"
        } else if lower.contains("rice") || lower.contains("pulao") || lower.contains("biryani") || lower.contains("khichdi") {
            return "https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80"
        } else if lower.contains("egg") || lower.contains("scramble") || lower.contains("omelette") || lower.contains("bhurji") {
            return "https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80"
        } else if lower.contains("pasta") || lower.contains("noodle") || lower.contains("spaghetti") {
            return "https://images.unsplash.com/photo-1621996346565-e3d5d6281691?auto=format&fit=crop&w=800&q=80"
        } else if lower.contains("chicken") || lower.contains("meat") || lower.contains("skillet") || lower.contains("roast") {
            return "https://images.unsplash.com/photo-1532550907401-a500c9a57435?auto=format&fit=crop&w=800&q=80"
        } else if lower.contains("toast") || lower.contains("bread") || lower.contains("sandwich") || lower.contains("wrap") {
            return "https://images.unsplash.com/photo-1528735602780-2552fd46c7af?auto=format&fit=crop&w=800&q=80"
        } else if lower.contains("salad") || lower.contains("snack") || lower.contains("protein bowl") {
            return "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=80"
        } else if lower.contains("yogurt") || lower.contains("curd") {
            return "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80"
        } else {
            // Default fresh gourmet meal photo
            return "https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&w=800&q=80"
        }
    }
}

struct RecipeImageView: View {
    let title: String
    var imageURL: String? = nil
    var iconName: String = "fork.knife"
    var contentMode: ContentMode = .fill
    var cornerRadius: CGFloat = 16

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange

    private var resolvedURLString: String? {
        if let url = imageURL, !url.isEmpty {
            return url
        }
        return RecipeImageCatalog.imageURL(for: title)
    }

    var body: some View {
        ZStack {
            // 1. Local Image Check
            if let localImage = UIImage(named: title) ?? UIImage(named: title.replacingOccurrences(of: " ", with: "_").lowercased()) {
                Image(uiImage: localImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if let urlString = resolvedURLString, let url = URL(string: urlString) {
                // 2. Remote CDN High-Definition Food Photography
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
                    Color(red: 0.96, green: 0.94, blue: 0.90),
                    Color(red: 0.91, green: 0.88, blue: 0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: iconName)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(zestOrange.opacity(0.85))
        }
    }
}
