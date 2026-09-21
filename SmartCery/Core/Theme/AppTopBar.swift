//
//  AppTopBar.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 21/07/26.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// Next-Gen iOS 27 Liquid Glass Interactive Top Bar Capsule with Dynamic Expansion.
struct AppTopBar: View {
    let title: String
    var subtitle: String? = nil
    var showBack: Bool = false
    var onBack: (() -> Void)? = nil
    var trailingIcon: String? = nil
    var badgeCount: Int = 0
    var onTrailingTap: (() -> Void)? = nil
    var isScrolled: Bool = false
    var isDarkHeader: Bool = false

    @State private var isExpanded: Bool = false
    @State private var isBreathingGlow: Bool = false
    @State private var specularOffset: CGFloat = -1.0

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // MARK: - MAIN COMPACT HEADER ROW
                HStack(alignment: .center, spacing: 10) {
                    if showBack {
                        backButton
                    }

                    // TAPPABLE TITLE & SUBTITLE HEADER REGION
                    Button {
                        HapticManager.impact(.medium)
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            VStack(alignment: (isScrolled && !isExpanded) ? .center : .leading, spacing: 1) {
                                HStack(spacing: 4) {
                                    Text(title)
                                        .font(.system(size: (isScrolled && !isExpanded) ? 14 : 16, weight: .black, design: .rounded))
                                        .foregroundStyle((isDarkHeader || isExpanded) ? Color.white : AppTheme.basilGreen)
                                        .lineLimit(1)

                                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down")
                                        .font(.system(size: isExpanded ? 12 : 10, weight: .bold))
                                        .foregroundStyle(isExpanded ? AppTheme.zestOrange : ((isDarkHeader || !isScrolled) ? Color.white.opacity(0.85) : AppTheme.basilGreen.opacity(0.7)))
                                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                                }

                                if let subtitle, !subtitle.isEmpty {
                                    Text(subtitle)
                                        .font(.system(size: (isScrolled && !isExpanded) ? 10 : 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(isExpanded ? Color.white.opacity(0.8) : ((isDarkHeader || !isScrolled) ? Color.white.opacity(0.85) : AppTheme.zestOrange))
                                        .lineLimit(1)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: (isScrolled && !isExpanded) ? .center : .leading)

                            // Quick "TAP TO EXPAND" Liquid Pill Indicator when collapsed
                            if !isExpanded && !isScrolled {
                                Text("INFO")
                                    .font(.system(size: 9, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppTheme.zestOrange.opacity(0.85), in: Capsule())
                                    .shadow(color: AppTheme.zestOrange.opacity(0.4), radius: 4, x: 0, y: 2)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    actionButtons
                }
                .padding(.horizontal, 14)
                .padding(.vertical, (isScrolled && !isExpanded) ? 8 : 10)

                // MARK: - EXPANDED LIQUID GLASS SUB-DETAILS SHEET
                if isExpanded {
                    VStack(spacing: 14) {
                        // Glass Divider
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.0), Color.white.opacity(0.35), Color.white.opacity(0.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 1)
                            .padding(.horizontal, 10)

                        // 1. DELIVERY LOCATION & LIVE RIDER ETA BREAKDOWN
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.zestOrange.opacity(0.2))
                                    .frame(width: 38, height: 38)

                                Image(systemName: "bolt.shield.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(AppTheme.zestOrange)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text("Express 10 Min Guarantee")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)

                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 6, height: 6)
                                        .scaleEffect(isBreathingGlow ? 1.4 : 0.8)
                                }

                                Text("Store: SmartCery Dark Store #4 • 1.2 km away")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.75))
                            }

                            Spacer(minLength: 0)

                            Text("ON TIME")
                                .font(.system(size: 9, weight: .black))
                                .foregroundStyle(Color.black)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white, in: Capsule())
                        }
                        .padding(12)
                        .background(Color.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                        // 2. SMART PANTRY & FRESHNESS LIVE SNAPSHOT
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.green)

                                Text("Smart Pantry Radar")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)

                                Spacer()

                                Text("Updated Live")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.6))
                            }

                            HStack(spacing: 8) {
                                expandedStatBadge(icon: "checkmark.seal.fill", title: "14 Pantry", color: .green)
                                expandedStatBadge(icon: "exclamationmark.triangle.fill", title: "2 Expiring", color: AppTheme.zestOrange)
                                expandedStatBadge(icon: "calendar.badge.clock", title: "7 Meals", color: .cyan)
                            }
                        }
                        .padding(12)
                        .background(Color.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                        // 3. CHEF ZEST AI LIVE SUGGESTION PILL
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(AppTheme.zestOrange)

                            VStack(alignment: .leading, spacing: 1) {
                                Text("Chef Zest AI Recommendation")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)

                                Text("\"Use Paneer & Tomatoes tonight before they expire in 2 days!\"")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.85))
                                    .lineLimit(1)
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(AppTheme.zestOrange)
                        }
                        .padding(10)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.zestOrange.opacity(0.3), AppTheme.basilGreen.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )

                        // 4. COLLAPSE HANDLE INDICATOR BAR
                        Button {
                            HapticManager.impact(.light)
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                                isExpanded = false
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Capsule()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: 36, height: 4)

                                Text("Tap to close")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            .padding(.top, 2)
                            .padding(.bottom, 6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .background(liquidGlass27Background)
            .padding(.horizontal, 14)
            .padding(.top, 4)
            .padding(.bottom, 6)
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.78), value: isExpanded)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: isScrolled)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                isBreathingGlow = true
            }
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                specularOffset = 1.0
            }
        }
    }

    // MARK: - EXPANDED STAT BADGE CHIP
    private func expandedStatBadge(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(color)

            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.12), in: Capsule())
    }

    // MARK: - NEXT-GEN iOS 27 LIQUID GLASS BACKGROUND
    private var liquidGlass27Background: some View {
        ZStack {
            // 1. Ultra-thin fluid blur layer
            RoundedRectangle(cornerRadius: isExpanded ? 28 : 24, style: .continuous)
                .fill(.ultraThinMaterial)

            // 2. Dynamic Liquid Gradient Shader Effect
            RoundedRectangle(cornerRadius: isExpanded ? 28 : 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: isDarkHeader || isExpanded ? [
                            Color(red: 0.10, green: 0.12, blue: 0.16).opacity(isExpanded ? 0.88 : 0.65),
                            Color(red: 0.18, green: 0.14, blue: 0.12).opacity(isExpanded ? 0.82 : 0.45)
                        ] : [
                            Color.white.opacity(0.85),
                            AppTheme.cream.opacity(0.70),
                            Color.white.opacity(0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // 3. Ambient Breathing Glass Aura Glow
            if isExpanded || isBreathingGlow {
                RoundedRectangle(cornerRadius: isExpanded ? 28 : 24, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.zestOrange.opacity(isBreathingGlow ? 0.18 : 0.08),
                                AppTheme.basilGreen.opacity(isBreathingGlow ? 0.12 : 0.04),
                                Color.clear
                            ],
                            center: .topTrailing,
                            startRadius: 10,
                            endRadius: isExpanded ? 300 : 150
                        )
                    )
            }
        }
        .overlay(
            // 4. Specular High-Gloss Rim & Metallic Liquid Border
            RoundedRectangle(cornerRadius: isExpanded ? 28 : 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: isExpanded ? [
                            AppTheme.zestOrange.opacity(0.9),
                            Color.white.opacity(0.8),
                            AppTheme.basilGreen.opacity(0.8)
                        ] : [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isExpanded ? 1.6 : 1.2
                )
        )
        .shadow(color: isExpanded ? AppTheme.zestOrange.opacity(0.25) : Color.black.opacity(0.10), radius: isExpanded ? 18 : 10, x: 0, y: isExpanded ? 8 : 4)
    }

    private var backButton: some View {
        Button {
            HapticManager.impact(.light)
            onBack?()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.55))
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.85), lineWidth: 1)
                    )

                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle((isDarkHeader || isExpanded) ? Color.white : AppTheme.basilGreen)
            }
            .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
    }

    private var actionButtons: some View {
        HStack(spacing: 5) {
            // Chef Zest AI Sparkle with Breathing Glow
            ZStack {
                Circle()
                    .fill(AppTheme.zestOrange.opacity(isBreathingGlow ? 0.28 : 0.12))
                    .scaleEffect(isBreathingGlow ? 1.15 : 0.92)

                Circle()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 28, height: 28)

                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppTheme.zestOrange)
            }
            .frame(width: 28, height: 28)

            if let trailingIcon {
                Button {
                    HapticManager.impact(.light)
                    onTrailingTap?()
                } label: {
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.55))
                                .frame(width: 28, height: 28)

                            Image(systemName: trailingIcon)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle((isDarkHeader || isExpanded) ? Color.white : AppTheme.basilGreen)
                        }

                        if badgeCount > 0 {
                            Text("\(badgeCount)")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.cream)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(AppTheme.zestOrange, in: Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.8), lineWidth: 1))
                                .offset(x: 4, y: -2)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.38))
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.9), Color.white.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

#Preview {
    VStack(spacing: 30) {
        AppTopBar(title: "SmartCery in 10 mins", subtitle: "HOME - Mochi Odd, Jamalpur", trailingIcon: "cart.fill", badgeCount: 3, isScrolled: false, isDarkHeader: true)
        AppTopBar(title: "SmartCery in 10 mins", subtitle: "HOME - Mochi Odd, Jamalpur", trailingIcon: "cart.fill", badgeCount: 3, isScrolled: true, isDarkHeader: true)
    }
    .padding(.vertical, 40)
    .background(
        LinearGradient(colors: [Color.blue, Color.green], startPoint: .topLeading, endPoint: .bottomTrailing)
    )
}
