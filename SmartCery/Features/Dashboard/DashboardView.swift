//
//  DashboardView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = DashboardViewModel()

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange
    private let cream = AppTheme.cream
    private let softCream = AppTheme.softCream
    private let elevatedSurface = AppTheme.elevatedSurface

    var body: some View {
        ZStack {
            softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    chefCard
                    statRow
                    pantrySetupCard
                    nextUpSection
                }
                .padding(.horizontal, 22)
                .padding(.top, 26)
                .padding(.bottom, 28)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Dashboard")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(zestOrange)

                Text(viewModel.greeting)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(basilGreen)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "cart.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(cream)
                .frame(width: 48, height: 48)
                .background(basilGreen, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var chefCard: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(zestOrange)
                .frame(width: 34, height: 34)
                .background(cream, in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text("Chef Zest")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(zestOrange)

                Text(viewModel.chefLine)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(basilGreen)
                    .lineSpacing(2)
            }
        }
        .padding(16)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var statRow: some View {
        HStack(spacing: 10) {
            ForEach(viewModel.stats) { stat in
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: stat.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(zestOrange)

                    Text(stat.value)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(basilGreen)

                    Text(stat.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(basilGreen.opacity(0.58))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    private var pantrySetupCard: some View {
        Button {
            router.openPantrySeed()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(zestOrange)
                        .frame(width: 58, height: 58)

                    Image(systemName: "cabinet.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(cream)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Set up your pantry")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(basilGreen)

                    Text("Tell SmartCery what you already have, so Chef Zest stops guessing like it is a group project.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(basilGreen.opacity(0.68))
                        .lineSpacing(2)
                }

                Spacer(minLength: 0)

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(basilGreen)
            }
            .padding(16)
            .background(cream, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(zestOrange.opacity(0.35), lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }

    private var nextUpSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next up")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(basilGreen)

            VStack(spacing: 10) {
                nextUpRow(iconName: "calendar", title: "Meal planner", subtitle: "Coming after pantry setup")
                nextUpRow(iconName: "bell.badge.fill", title: "Expiry alerts", subtitle: "Soon: rescue food before it becomes fridge drama")
            }
        }
    }

    private func nextUpRow(iconName: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(zestOrange)
                .frame(width: 34, height: 34)
                .background(cream, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(basilGreen)

                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(basilGreen.opacity(0.62))
            }

            Spacer()
        }
        .padding(14)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppRouter())
}

