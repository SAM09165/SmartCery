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
    @EnvironmentObject private var store: AppStore
    @StateObject private var viewModel = DashboardViewModel()
    @State private var isPulsing = false

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange
    private let cream = AppTheme.cream
    private let softCream = AppTheme.softCream
    private let elevatedSurface = AppTheme.elevatedSurface

    var body: some View {
        ZStack {
            softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    liveBlinkitBanner
                    chefCard
                    statRow
                    pantrySetupCard
                    nextUpSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTopBar(
                    title: "Dashboard",
                    subtitle: store.profile.map { "Hey, \($0.displayName)." } ?? viewModel.greeting,
                    trailingIcon: "cart.fill",
                    onTrailingTap: { tabRouter.selectedTab = .market }
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea(edges: .top)
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.updateTimeOfDay()
        }
    }

    private var liveBlinkitBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isPulsing ? 1.35 : 0.85)
                    .opacity(isPulsing ? 1.0 : 0.4)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true)) {
                            isPulsing = true
                        }
                    }

                Text(viewModel.timeOfDay.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Image(systemName: viewModel.timeOfDay.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))
            }

            Text(viewModel.timeOfDay.subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))

            HStack(spacing: 6) {
                Text(viewModel.livePromos[viewModel.activeBannerIndex])
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.22), in: Capsule())
                    .id("banner_\(viewModel.activeBannerIndex)")
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: viewModel.timeOfDay.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
        .shadow(color: viewModel.timeOfDay.gradientColors.first?.opacity(0.32) ?? .clear, radius: 10, x: 0, y: 5)
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

                Text(store.pantry.isEmpty ? viewModel.chefLine : "You have \(store.pantry.count) pantry items. Let’s use what is already in your kitchen first.")
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
            ForEach(stats) { stat in
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

    private var stats: [DashboardStat] {
        [
            DashboardStat(title: "Pantry", value: "\(store.pantry.count) items", iconName: "cabinet.fill"),
            DashboardStat(title: "Expiring", value: "\(store.pantry.filter { if case .fresh = Expirychecker.status(for: $0.expiryDate) { return false }; return true }.count)", iconName: "clock.badge.exclamationmark.fill"),
            DashboardStat(title: "List", value: store.groceryList.isEmpty ? "Empty" : "\(store.groceryList.count) items", iconName: "cart.fill")
        ]
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
                Button {
                    tabRouter.selectedTab = .mealPlanner
                } label: {
                    nextUpRow(iconName: "calendar", title: "Meal planner", subtitle: "Plan meals with pantry items")
                }
                .buttonStyle(.plain)

                nextUpRow(iconName: "bell.badge.fill", title: "Expiry alerts", subtitle: "Rescue food before it becomes fridge drama")
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

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(basilGreen.opacity(0.4))
        }
        .padding(14)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppRouter())
        .environmentObject(TabRouter())
        .environmentObject(AppStore())
}
