//
//  AppTopBar.swift
//  SmartCery
//
//  Floating Liquid Glass Interactive Top Bar Capsule with Progressive Disclosure.
//  Collapsed: Profile/avatar, Greeting/title, Single essential action.
//  Expanded: Today's health overview, macro snapshot, streak, and quick alert.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct AppTopBar: View {
    let title: String
    var subtitle: String? = nil
    var avatarInitials: String? = nil
    var onAvatarTap: (() -> Void)? = nil
    var showBack: Bool = false
    var onBack: (() -> Void)? = nil
    var trailingIcon: String? = nil
    var badgeCount: Int = 0
    var onTrailingTap: (() -> Void)? = nil
    var isScrolled: Bool = false
    var isDarkHeader: Bool = false

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // MARK: - COLLAPSED STATE ROW
                HStack(alignment: .center, spacing: 10) {
                    if showBack {
                        backButton
                    } else if let avatarInitials, !avatarInitials.isEmpty {
                        avatarButton(initials: avatarInitials)
                    }

                    // Tappable Header: Progressive disclosure expand/collapse
                    Button {
                        HapticManager.impact(.medium)
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.80)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            VStack(alignment: isScrolled && !isExpanded ? .center : .leading, spacing: 1) {
                                HStack(spacing: 5) {
                                    Text(title)
                                        .font(.system(size: isScrolled && !isExpanded ? 14 : 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(headerTextColor)
                                        .lineLimit(1)

                                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(isExpanded ? AppTheme.warmAccent : headerTextColor.opacity(0.65))
                                }

                                if let subtitle, !subtitle.isEmpty {
                                    Text(subtitle)
                                        .font(.system(size: isScrolled && !isExpanded ? 10 : 11, weight: .medium, design: .rounded))
                                        .foregroundStyle(isExpanded ? AppTheme.textSecondary : (isDarkHeader ? Color.white.opacity(0.85) : AppTheme.textSecondary))
                                        .lineLimit(1)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: isScrolled && !isExpanded ? .center : .leading)

                            // Clean indicator pill when collapsed
                            if !isExpanded && !isScrolled {
                                HStack(spacing: 3) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 9, weight: .bold))
                                    Text("OVERVIEW")
                                        .font(.system(size: 8, weight: .bold, design: .rounded))
                                }
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3.5)
                                .background(AppTheme.primary, in: Capsule())
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    // Single Important Action
                    if let trailingIcon {
                        trailingActionButton(icon: trailingIcon)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, isScrolled && !isExpanded ? 8 : 10)

                // MARK: - EXPANDED PROGRESSIVE DISCLOSURE PANEL
                if isExpanded {
                    VStack(spacing: 12) {
                        Rectangle()
                            .fill(AppTheme.borderSubtle.opacity(0.5))
                            .frame(height: 1)
                            .padding(.horizontal, 6)

                        // 1. Health & Macro Quick Overview
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primary.opacity(0.14))
                                    .frame(width: 38, height: 38)

                                Image(systemName: "flame.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(AppTheme.terracotta)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Today's Nutrition Goals")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(expandedTextColor)

                                Text("2,150 kcal Target • 110g Protein Goal")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(expandedTextColor.opacity(0.75))
                            }

                            Spacer(minLength: 0)

                            HStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 10, weight: .bold))
                                Text("5 Day Streak")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(AppTheme.warmAccent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.warmAccent.opacity(0.14), in: Capsule())
                        }
                        .padding(10)
                        .background(AppTheme.cardSurface.opacity(0.6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        // 2. Kitchen Radar & Fast Delivery Shortcut
                        HStack(spacing: 8) {
                            statItem(icon: "archivebox.fill", label: "Stocked", value: "14 Items", color: AppTheme.primary)
                            statItem(icon: "clock.badge.exclamationmark.fill", label: "Expiring", value: "2 Items", color: AppTheme.terracotta)
                            statItem(icon: "bicycle", label: "Express", value: "10 Mins", color: AppTheme.secondary)
                        }

                        // 3. Collapse Handle
                        Button {
                            HapticManager.impact(.light)
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.80)) {
                                isExpanded = false
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.up")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Close overview")
                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(expandedTextColor.opacity(0.65))
                            .padding(.vertical, 3)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(glassCapsuleBackground)
            .padding(.horizontal, 16)
            .padding(.top, 2)
            .padding(.bottom, 6)
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.80), value: isExpanded)
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: isScrolled)
    }

    private var headerTextColor: Color {
        if isExpanded { return AppTheme.textPrimary }
        if isDarkHeader && !isScrolled { return Color.white }
        return AppTheme.textPrimary
    }

    private var expandedTextColor: Color {
        AppTheme.textPrimary
    }

    // MARK: - Avatar Button
    private func avatarButton(initials: String) -> some View {
        Button {
            HapticManager.impact(.light)
            onAvatarTap?()
        } label: {
            ZStack {
                Circle()
                    .fill(AppTheme.primary)
                    .frame(width: 32, height: 32)

                Text(initials)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Back Button
    private var backButton: some View {
        Button {
            HapticManager.impact(.light)
            onBack?()
        } label: {
            ZStack {
                Circle()
                    .fill(AppTheme.cardSurface.opacity(0.7))
                    .frame(width: 32, height: 32)
                    .overlay(Circle().stroke(AppTheme.borderSubtle, lineWidth: 1))

                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(headerTextColor)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Trailing Action Button
    private func trailingActionButton(icon: String) -> some View {
        Button {
            HapticManager.impact(.light)
            onTrailingTap?()
        } label: {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Circle()
                        .fill(AppTheme.cardSurface.opacity(0.7))
                        .frame(width: 32, height: 32)
                        .overlay(Circle().stroke(AppTheme.borderSubtle, lineWidth: 1))

                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(headerTextColor)
                }

                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(AppTheme.terracotta, in: Capsule())
                        .offset(x: 4, y: -2)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stat Item in Expanded Panel
    private func statItem(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(expandedTextColor)
                .lineLimit(1)

            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(expandedTextColor.opacity(0.65))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(AppTheme.cardSurface.opacity(0.6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Liquid Glass Background
    private var glassCapsuleBackground: some View {
        RoundedRectangle(cornerRadius: isExpanded ? 24 : 22, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: isExpanded ? 24 : 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.40),
                                Color.white.opacity(0.12),
                                Color.black.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: isExpanded ? 16 : 10, x: 0, y: isExpanded ? 8 : 4)
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}
