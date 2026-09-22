//
//  SmartCeryFloatingBottomBar.swift
//  SmartCery
//
//  Floating Liquid Glass Bottom Navigation Bar.
//  Floats over app content with true translucent material, specular edge highlight,
//  haptic feedback, and fluid spring transitions.
//

import SwiftUI

struct SmartCeryFloatingBottomBar: View {
    @Binding var selectedTab: MainTab
    var cartCount: Int = 0
    @Namespace private var tabNamespace

    private let tabs: [MainTab] = MainTab.mainTabs

    var body: some View {
        HStack(spacing: 4) {
            ForEach(tabs) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .liquidGlass(cornerRadius: AppRadius.pill, isPill: true)
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private func tabButton(_ tab: MainTab) -> some View {
        let isSelected = selectedTab == tab

        Button {
            if selectedTab != tab {
                HapticManager.impact(.light)
                withAnimation(.spring(response: 0.36, dampingFraction: 0.78)) {
                    selectedTab = tab
                }
            }
        } label: {
            HStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.iconName)
                        .font(.system(size: isSelected ? 15 : 16, weight: isSelected ? .bold : .medium))
                        .foregroundStyle(isSelected ? Color.white : AppTheme.textSecondary)

                    // Badge for Shop cart
                    if tab == .market && cartCount > 0 {
                        Circle()
                            .fill(AppTheme.terracotta)
                            .frame(width: 7, height: 7)
                            .offset(x: 3, y: -3)
                    }
                }
                .frame(width: 22, height: 22)

                if isSelected {
                    Text(tab.title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.85).combined(with: .opacity),
                            removal: .scale(scale: 0.85).combined(with: .opacity)
                        ))
                }
            }
            .padding(.horizontal, isSelected ? 12 : 10)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.primary,
                                    AppTheme.primary.opacity(0.88)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .matchedGeometryEffect(id: "ACTIVE_TAB_PILL", in: tabNamespace)
                        .shadow(color: AppTheme.primary.opacity(0.35), radius: 6, x: 0, y: 3)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: isSelected ? .infinity : nil)
    }
}

#Preview {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        VStack {
            Spacer()
            SmartCeryFloatingBottomBar(selectedTab: .constant(.dashboard), cartCount: 3)
        }
    }
}
