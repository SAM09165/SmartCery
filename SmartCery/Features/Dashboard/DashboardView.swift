//
//  DashboardView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabRouter: TabRouter
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
                    chefCard
                    statRow
                    pantrySetupCard
                    nextUpSection
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTopBar(
                    title: "Dashboard",
                    subtitle: viewModel.greeting,
                    trailingIcon: "cart.fill",
                    onTrailingTap: { tabRouter.selectedTab = .market }
                )
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea(edges: .top)
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
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
        .environmentObject(TabRouter())
}
