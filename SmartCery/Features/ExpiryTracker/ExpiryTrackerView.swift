//
//  ExpiryTrackerView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct ExpiryTrackerView: View {
    @StateObject private var viewModel = ExpiryTrackerViewModel()
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var tabRouter: TabRouter
    @State private var showingChefZest = false
    @State private var isScrolled = false

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange
    private let cream = AppTheme.cream
    private let softCream = AppTheme.softCream
    private let elevatedSurface = AppTheme.elevatedSurface

    var body: some View {
        ZStack {
            softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Geometry Reader for Scroll Offset Tracking
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("expiryScroll")).minY
                        )
                    }
                    .frame(height: 0)

                    // 1. CHEF ZEST RECIPE RESCUE HERO CARD
                    rescueCard

                    // 2. SPOILAGE & FRESHNESS RADAR HEATMAP
                    spoilageRadarCard

                    // 3. SEGMENTED EXPIRY FILTER RIBBON
                    filterControlRibbon

                    // 4. EXPIRY ITEM LIST
                    expiryList
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .coordinateSpace(name: "expiryScroll")
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
                    title: "Expiry & Freshness Radar",
                    subtitle: viewModel.subtitleLine,
                    trailingIcon: "sparkles",
                    onTrailingTap: {
                        HapticManager.impact(.medium)
                        showingChefZest = true
                    },
                    isScrolled: isScrolled
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task { viewModel.replaceItems(store.pantry) }
        .onChange(of: store.pantry) { _, items in viewModel.replaceItems(items) }
        .sheet(isPresented: $showingChefZest) {
            ChefZestView()
                .environmentObject(store)
                .environmentObject(tabRouter)
        }
    }

    // MARK: - 1. RECIPE RESCUE HERO CARD
    private var rescueCard: some View {
        Button {
            HapticManager.impact(.medium)
            showingChefZest = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(cream)
                        .frame(width: 44, height: 44)

                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(zestOrange)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("RECIPE RESCUE AI")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(cream.opacity(0.85))
                            .tracking(1.0)

                        Text("HIGH PRIORITY")
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(zestOrange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(cream, in: Capsule())
                    }

                    Text(rescueTitle)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(cream)
                        .lineLimit(1)

                    Text(rescueSubtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(cream.opacity(0.88))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(cream)
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [basilGreen, Color(red: 0.10, green: 0.40, blue: 0.22)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .shadow(color: basilGreen.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var rescueTitle: String {
        guard let item = viewModel.nextRescueItem else {
            return "Your Pantry is Fresh & Healthy"
        }
        return "Cook \(item.entry.name) Today!"
    }

    private var rescueSubtitle: String {
        guard let item = viewModel.nextRescueItem else {
            return "No items need urgent attention right now."
        }
        return "\(item.entry.quantity) • \(item.statusTitle). Tap to generate rescue recipe."
    }

    // MARK: - 2. SPOILAGE RADAR HEATMAP CARD
    private var spoilageRadarCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(zestOrange)

                    Text("FRESHNESS RADAR")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(basilGreen.opacity(0.7))
                        .tracking(1.0)
                }

                Spacer()

                Text("Total: \(store.pantry.count) items")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen.opacity(0.6))
            }

            // Visual Multi-Color Heatmap Progress Bar
            GeometryReader { geo in
                let total = CGFloat(max(1, store.pantry.count))
                let availableWidth = max(0, geo.size.width)
                let activeSegments = (viewModel.freshCount > 0 ? 1 : 0) + (viewModel.expiringSoonCount > 0 ? 1 : 0) + (viewModel.expiredCount > 0 ? 1 : 0)
                let totalSpacing = CGFloat(max(0, activeSegments - 1)) * 3.0
                let barWidth = max(0, availableWidth - totalSpacing)

                HStack(spacing: 3) {
                    if viewModel.freshCount > 0 {
                        Capsule()
                            .fill(Color.green)
                            .frame(width: max(4, (CGFloat(viewModel.freshCount) / total) * barWidth))
                    }

                    if viewModel.expiringSoonCount > 0 {
                        Capsule()
                            .fill(zestOrange)
                            .frame(width: max(4, (CGFloat(viewModel.expiringSoonCount) / total) * barWidth))
                    }

                    if viewModel.expiredCount > 0 {
                        Capsule()
                            .fill(Color.red)
                            .frame(width: max(4, (CGFloat(viewModel.expiredCount) / total) * barWidth))
                    }
                }
            }
            .frame(height: 8)

            // Stat Summary Chips
            HStack(spacing: 10) {
                summaryTile(icon: "checkmark.seal.fill", count: viewModel.freshCount, label: "Fresh", color: .green)
                summaryTile(icon: "exclamationmark.triangle.fill", count: viewModel.expiringSoonCount, label: "Expiring Soon", color: zestOrange)
                summaryTile(icon: "xmark.octagon.fill", count: viewModel.expiredCount, label: "Expired", color: .red)
            }
        }
        .padding(16)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.8), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    private func summaryTile(icon: String, count: Int, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 1) {
                Text("\(count)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(basilGreen)

                Text(label)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen.opacity(0.6))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - 3. FILTER CONTROL RIBBON
    private var filterControlRibbon: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ExpiryFilter.allCases) { filter in
                    let isSelected = filter == viewModel.selectedFilter

                    Button {
                        HapticManager.impact(.light)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                            viewModel.selectedFilter = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(isSelected ? cream : basilGreen)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isSelected ? basilGreen : elevatedSurface, in: Capsule())
                            .shadow(color: isSelected ? basilGreen.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - 4. EXPIRY ITEM LIST
    private var expiryList: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("\(viewModel.selectedFilter.rawValue) Items (\(viewModel.visibleItems.count))")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(basilGreen)

            if viewModel.visibleItems.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.visibleItems) { item in
                        liquidExpiryCard(item)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(cream)
                    .frame(width: 60, height: 60)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.green)
            }

            VStack(spacing: 4) {
                Text("No Items in This Filter")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen)

                Text("Switch filters to inspect the rest of your kitchen inventory.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(basilGreen.opacity(0.68))
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - LIQUID EXPIRY CARD
    private func liquidExpiryCard(_ item: ExpiryTrackerItem) -> some View {
        let color = statusColor(for: item.status)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(cream)
                        .frame(width: 44, height: 44)

                    Image(systemName: item.entry.iconName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.entry.name)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(basilGreen)

                    HStack(spacing: 8) {
                        Text(item.entry.quantity)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(basilGreen.opacity(0.65))

                        Text("•")
                            .font(.system(size: 10))
                            .foregroundStyle(basilGreen.opacity(0.3))

                        Text(item.entry.category)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(zestOrange)
                    }

                    Text(item.actionHint)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(basilGreen.opacity(0.7))
                        .padding(.top, 2)
                }

                Spacer(minLength: 0)

                statusBadge(item.statusTitle, status: item.status)
            }

            // Action Ribbon Buttons
            HStack(spacing: 10) {
                // Extend +3 Days
                Button {
                    HapticManager.impact(.light)
                    store.extendPantryItem(item.id, by: 3)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 11, weight: .bold))

                        Text("+3 Days")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(basilGreen)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(cream, in: Capsule())
                }
                .buttonStyle(.plain)

                // Mark Used
                Button {
                    HapticManager.impact(.medium)
                    withAnimation {
                        store.removePantryItem(item.id)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))

                        Text("Mark Used")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(cream)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(basilGreen, in: Capsule())
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)
            }
        }
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(elevatedSurface)

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.4))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.9), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }

    private func statusBadge(_ text: String, status: ExpiryStatus) -> some View {
        let color = statusColor(for: status)

        return Text(text)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12), in: Capsule())
    }

    private func statusColor(for status: ExpiryStatus) -> Color {
        switch status {
        case .expired:
            return .red
        case .expiringSoon:
            return zestOrange
        case .fresh:
            return .green
        }
    }
}

#Preview {
    ExpiryTrackerView()
        .environmentObject(AppStore())
        .environmentObject(TabRouter())
}
