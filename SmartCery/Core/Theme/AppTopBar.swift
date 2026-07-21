//
//  AppTopBar.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 21/07/26.
//

import SwiftUI


struct AppTopBar: View {
    let title: String
    var subtitle: String? = nil
    var showBack: Bool = false
    var onBack: (() -> Void)? = nil
    var trailingIcon: String? = nil
    var onTrailingTap: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if showBack {
                Button {
                    onBack?()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen)
                        .frame(width: 34, height: 34)
                        .background(AppTheme.cream, in: Circle())
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.basilGreen.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)

            if let trailingIcon {
                Button {
                    onTrailingTap?()
                } label: {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.cream)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.basilGreen, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        AppTopBar(title: "Dashboard", subtitle: "Hey, kitchen main character.", trailingIcon: "cart.fill")
        AppTopBar(title: "Market", subtitle: "3 items in your cart", showBack: true, trailingIcon: "magnifyingglass")
        AppTopBar(title: "Settings")
    }
    .padding()
    .background(AppTheme.softCream)
}
