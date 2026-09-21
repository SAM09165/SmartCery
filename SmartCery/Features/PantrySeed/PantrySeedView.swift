//
//  PantrySeedView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

enum PantrySeedMode {
    case firstTime
    case addItems
}

struct PantrySeedView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var sessionManager: SessionManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PantrySeedViewModel()
    @State private var isScrolled = false

    let mode: PantrySeedMode

    private let columns = [
        GridItem(.adaptive(minimum: 132), spacing: 12)
    ]

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange
    private let cream = AppTheme.cream
    private let softCream = AppTheme.softCream
    private let elevatedSurface = AppTheme.elevatedSurface

    var body: some View {
        ZStack {
            softCream.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: proxy.frame(in: .named("pantrySeedScroll")).minY
                            )
                        }
                        .frame(height: 0)

                        headerCard
                        chefBubble
                        pantryGrid
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 18)
                }
                .coordinateSpace(name: "pantrySeedScroll")
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
                        title: mode == .firstTime ? "Select Pantry Items" : "Add Pantry Items",
                        subtitle: "Pick items you already have in stock",
                        showBack: mode == .addItems,
                        onBack: { dismiss() },
                        isScrolled: isScrolled
                    )
                }

                bottomBar
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if let profile = store.profile {
                viewModel.syncDiet(profile.dietPreference)
            }
        }
        .onChange(of: store.profile) { _, newProfile in
            if let newProfile = newProfile {
                viewModel.syncDiet(newProfile.dietPreference)
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(mode == .firstTime ? "Pantry Setup" : "Add to Pantry")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(zestOrange)

                    Text(mode == .firstTime ? "What is already in your kitchen?" : "What did you just add?")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(basilGreen)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                        viewModel.clearSelection()
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(basilGreen)
                        .frame(width: 42, height: 42)
                        .background(cream, in: Circle())
                }
                .accessibilityLabel("Clear selected pantry items")
            }

            if mode == .firstTime, !viewModel.subtitle.isEmpty {
                Text(viewModel.subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(basilGreen.opacity(0.72))
                    .lineSpacing(2)
            }
        }
        .padding(16)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var chefBubble: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(zestOrange)
                .frame(width: 28)

            Text(mode == .firstTime ? viewModel.chefLine : "Adding something new! Pick items to add, then save.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(basilGreen)
                .lineSpacing(2)

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var pantryGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.items) { item in
                pantryItemButton(item)
            }
        }
    }

    private func pantryItemButton(_ item: PantrySeedItem) -> some View {
        let isSelected = viewModel.isSelected(item)

        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                viewModel.toggle(item)
            }
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: item.iconName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(isSelected ? cream : zestOrange)
                        .frame(width: 34, height: 34)

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isSelected ? cream : basilGreen.opacity(0.5))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isSelected ? cream : basilGreen)

                    Text(item.category)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isSelected ? cream.opacity(0.72) : basilGreen.opacity(0.58))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 124, alignment: .leading)
            .background(isSelected ? basilGreen : cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? zestOrange : basilGreen.opacity(0.08), lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    viewModel.saveSelection()
                    store.addPantryItems(viewModel.selectedItems.map(makePantryItem))
                    if mode == .firstTime {
                        store.completeOnboarding()
                        try? await FirebaseService.shared.markPantrySeedCompleted()
                        sessionManager.markPantrySeedCompleted()
                        router.completePantrySeed()
                    } else {
                        dismiss()
                    }
                }
            } label: {
                HStack {
                    Text(mode == .addItems ? "Add \(viewModel.selectedCount) Items" : viewModel.primaryButtonTitle)
                    Image(systemName: viewModel.selectedCount == 0 ? "arrow.right" : "checkmark")
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(cream)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(basilGreen, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            Text(mode == .addItems ? "You can always add more later." : "You can edit this later. Your future grocery list is already nervous.")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(basilGreen.opacity(0.58))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 18)
        .background(softCream)
    }

    private func makePantryItem(_ item: PantrySeedItem) -> PantryItem {
        let expiryDays: Int? = switch item.category {
        case "Dairy": 5
        case "Protein": 3
        case "Veg", "Bakery": 4
        default: nil
        }
        let expiryDate = expiryDays.flatMap { Calendar.current.date(byAdding: .day, value: $0, to: .now) }
        return PantryItem(name: item.name, category: item.category, quantity: "1 item", expiryDate: expiryDate, iconName: item.iconName)
    }
}

#Preview {
    Group {
            PantrySeedView(mode: .firstTime)
            .environmentObject(AppRouter()).environmentObject(AppStore()).environmentObject(SessionManager())

            PantrySeedView(mode: .addItems)
            .environmentObject(AppRouter()).environmentObject(AppStore())
    }
}
