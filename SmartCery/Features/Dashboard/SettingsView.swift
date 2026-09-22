//
//  SettingsView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabRouter: TabRouter
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var sessionManager: SessionManager

    @AppStorage("smartcery.settings.notifications-enabled") private var notificationsEnabled = true
    @AppStorage("smartcery.settings.expiry-alerts-enabled") private var expiryAlertsEnabled = true
    @AppStorage("smartcery.settings.meal-plan-reminders-enabled") private var mealPlanRemindersEnabled = false
    @State private var selectedSheet: MoreSheet?
    @State private var isScrolled = false

    private var profile: UserProfile {
        store.profile ?? UserProfile()
    }

    private var initials: String {
        let words = profile.displayName.split(separator: " ")
        return words.prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    // Geometry Reader for Scroll Offset Tracking
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("settingsScroll")).minY
                        )
                    }
                    .frame(height: 0)

                    // 1. PROFILE HEADER
                    profileHeaderCard

                    // 2. HEALTH & MACRO OVERVIEW
                    healthOverviewSection

                    // 3. ORDERS & EXPRESS DELIVERIES
                    ordersSection

                    // 4. SAVED RECIPES & MEAL PLANS SHORTCUTS
                    savedContentSection

                    // 5. KITCHEN ACHIEVEMENTS
                    achievementsSection

                    // 6. PREFERENCES & SETTINGS
                    preferencesSection

                    // 7. APP OPTIONS & SUPPORT
                    appOptionsSection

                    // 8. SIGN OUT BUTTON
                    signOutButton
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.xxxl)
            }
            .coordinateSpace(name: "settingsScroll")
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
                    title: "Profile & Health",
                    subtitle: "Personal metrics, diet & preferences",
                    isScrolled: isScrolled
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedSheet) { sheet in
            MoreDetailSheet(sheet: sheet)
                .environmentObject(store)
        }
    }

    // MARK: - 1. PROFILE HEADER CARD
    private var profileHeaderCard: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppTheme.primary)
                    .frame(width: 58, height: 58)

                Text(initials.isEmpty ? "SH" : initials)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(AppTheme.elevatedSurface)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(profile.displayName.capitalized)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                HStack(spacing: 6) {
                    Image(systemName: profile.dietPreference.badgeIcon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(profile.dietPreference.isStrictVeg ? Color.green : AppTheme.warmAccent)

                    Text(profile.dietPreference.rawValue)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(profile.dietPreference.isStrictVeg ? Color.green : AppTheme.warmAccent)
                }

                Text("\(Int(profile.heightCm))cm · \(Int(profile.weightKg))kg · Age \(profile.age)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer(minLength: 0)

            Button {
                HapticManager.impact(.medium)
                selectedSheet = .profile
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.surface, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.md)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: - 2. HEALTH & MACRO OVERVIEW
    private var healthOverviewSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            sectionHeader("Health & Macro Targets", icon: "heart.fill")

            HStack(spacing: AppSpacing.sm) {
                healthMetricCard(
                    title: "Target Cal",
                    value: "\(profile.calculatedTargetCalories) kcal",
                    icon: "flame.fill",
                    color: AppTheme.warmAccent
                )

                healthMetricCard(
                    title: "Protein Target",
                    value: "\(profile.calculatedTargetProtein)g",
                    icon: "bolt.heart.fill",
                    color: AppTheme.primary
                )

                healthMetricCard(
                    title: "Daily TDEE",
                    value: "\(Int(profile.tdee.rounded())) kcal",
                    icon: "figure.walk",
                    color: Color.teal
                )
            }
        }
    }

    private func healthMetricCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.sm)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - 3. ORDERS & EXPRESS DELIVERIES
    private var ordersSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                sectionHeader("Orders & Deliveries", icon: "box.truck.fill")

                Spacer()

                Button {
                    tabRouter.selectedTab = .market
                } label: {
                    Text("Express Store")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primary)
                }
                .buttonStyle(.plain)
            }

            Button {
                tabRouter.selectedTab = .market
            } label: {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primary.opacity(0.12))
                            .frame(width: 42, height: 42)

                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(AppTheme.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("10-Min Smart Delivery")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)

                            Text("ACTIVE")
                                .font(.system(size: 8, weight: .black))
                                .foregroundStyle(AppTheme.elevatedSurface)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green, in: Capsule())
                        }

                        Text("Delivering to 21 Park Street, Suite 4B")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.6))
                }
                .padding(AppSpacing.md)
                .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - 4. SAVED RECIPES & MEAL PLANS SHORTCUTS
    private var savedContentSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            sectionHeader("Saved & Shortcuts", icon: "bookmark.fill")

            HStack(spacing: AppSpacing.sm) {
                shortcutCard(
                    title: "Meal Plans",
                    subtitle: "Daily 4-meal flow",
                    icon: "calendar",
                    badge: "\(store.plannedMealsCount) planned"
                ) {
                    tabRouter.selectedTab = .mealPlanner
                }

                shortcutCard(
                    title: "Pantry Staples",
                    subtitle: "Live inventory radar",
                    icon: "cabinet.fill",
                    badge: "\(store.pantry.count) stocked"
                ) {
                    tabRouter.selectedTab = .pantry
                }
            }
        }
    }

    private func shortcutCard(title: String, subtitle: String, icon: String, badge: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.impact(.light)
            action()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppTheme.primary)

                    Spacer()

                    Text(badge)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.primary.opacity(0.1), in: Capsule())
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 5. KITCHEN ACHIEVEMENTS
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            sectionHeader("Kitchen Achievements", icon: "trophy.fill")

            HStack(spacing: AppSpacing.sm) {
                achievementBadge(title: "5-Day Streak", subtitle: "Consistent Meals", icon: "flame.fill", color: AppTheme.warmAccent)
                achievementBadge(title: "Zero-Waste", subtitle: "Pantry Rescued", icon: "arrow.triangle.2.circlepath", color: AppTheme.primary)
                achievementBadge(title: "Diet Champion", subtitle: profile.dietPreference.rawValue, icon: "checkmark.seal.fill", color: Color.teal)
            }
        }
    }

    private func achievementBadge(title: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(color)

            VStack(spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(subtitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .padding(.horizontal, 4)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
    }

    // MARK: - 6. PREFERENCES SECTION
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            sectionHeader("Preferences", icon: "slider.horizontal.3")

            VStack(spacing: 0) {
                preferenceToggle("Push Notifications", iconName: "bell.fill", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if !enabled {
                            NotificationService.shared.clearAllNotifications()
                        } else {
                            NotificationService.shared.requestPermission()
                            if expiryAlertsEnabled {
                                NotificationService.shared.syncExpiryNotifications(for: store.pantry)
                            }
                        }
                    }

                Divider()
                    .padding(.leading, 52)
                    .overlay(AppTheme.borderSubtle.opacity(0.6))

                preferenceToggle("Expiry Alerts", iconName: "clock.badge.exclamationmark.fill", isOn: $expiryAlertsEnabled)
                    .onChange(of: expiryAlertsEnabled) { _, enabled in
                        if !enabled {
                            NotificationService.shared.clearAllNotifications()
                        } else if notificationsEnabled {
                            NotificationService.shared.syncExpiryNotifications(for: store.pantry)
                        }
                    }

                Divider()
                    .padding(.leading, 52)
                    .overlay(AppTheme.borderSubtle.opacity(0.6))

                preferenceToggle("Meal Plan Reminders", iconName: "calendar.badge.clock", isOn: $mealPlanRemindersEnabled)
            }
            .padding(.vertical, 4)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )
        }
    }

    private func preferenceToggle(_ title: String, iconName: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppTheme.warmAccent)
                .frame(width: 36, height: 36)
                .background(AppTheme.surface, in: Circle())

            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Spacer(minLength: 0)

            Toggle(title, isOn: isOn)
                .labelsHidden()
                .tint(AppTheme.primary)
                .onChange(of: isOn.wrappedValue) { _, _ in
                    HapticManager.impact(.light)
                }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - 7. APP OPTIONS SECTION
    private var appOptionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            sectionHeader("Health & Support", icon: "shield.fill")

            VStack(spacing: 8) {
                optionRow("Diet & Strict Boundaries", subtitle: profile.dietPreference.rawValue, iconName: "leaf.fill", sheet: .diet)
                optionRow("Edit Personal Health Metrics", subtitle: "Height, Weight, Workout level", iconName: "figure.walk", sheet: .profile)
                optionRow("Chef Zest AI Guidance", subtitle: "How BMR, TDEE & Veg rules work", iconName: "sparkles", sheet: .help)
                optionRow("Privacy & Local Data", subtitle: "On-device encrypted storage", iconName: "lock.shield.fill", sheet: .privacy)
                optionRow("Contact Support", subtitle: "Feedback & assistance", iconName: "bubble.left.and.bubble.right.fill", sheet: .contact)
            }
        }
    }

    private func optionRow(_ title: String, subtitle: String, iconName: String, sheet: MoreSheet) -> some View {
        Button {
            HapticManager.impact(.light)
            selectedSheet = sheet
        } label: {
            HStack(spacing: 14) {
                Image(systemName: iconName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
            }
            .padding(AppSpacing.md)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 8. SIGN OUT BUTTON
    private var signOutButton: some View {
        Button {
            HapticManager.impact(.heavy)
            store.signOut()
            sessionManager.signOut()
            router.destination = .auth
        } label: {
            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.terracotta)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.terracotta.opacity(0.1), in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(AppTheme.textPrimary)
    }
}

private enum MoreSheet: Identifiable {
    case profile
    case diet
    case privacy
    case help
    case contact

    var id: String {
        switch self {
        case .profile: return "profile"
        case .diet: return "diet"
        case .privacy: return "privacy"
        case .help: return "help"
        case .contact: return "contact"
        }
    }

    var title: String {
        switch self {
        case .profile: return "Personal Health Profile"
        case .diet: return "Strict Diet Preference"
        case .privacy: return "Privacy & Data"
        case .help: return "Chef Zest Guidance"
        case .contact: return "Contact Support"
        }
    }
}

private struct MoreDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppStore
    let sheet: MoreSheet

    @State private var tempProfile: UserProfile = UserProfile()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        if sheet == .profile || sheet == .diet {
                            editableProfileForm
                        } else {
                            defaultInfoView
                        }
                    }
                    .padding(AppSpacing.md)
                }
            }
            .navigationTitle(sheet.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.primary)
                }

                if sheet == .profile || sheet == .diet {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            store.setProfile(tempProfile)
                            dismiss()
                        }
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primary)
                    }
                }
            }
            .onAppear {
                if let p = store.profile {
                    tempProfile = p
                }
            }
        }
    }

    private var editableProfileForm: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("Edit Health Profile & Strict Diet")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            VStack(alignment: .leading, spacing: 10) {
                Text("Dietary Preference")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                VStack(spacing: 8) {
                    ForEach(DietaryPreference.allCases, id: \.self) { diet in
                        let isSelected = tempProfile.dietPreference == diet
                        Button {
                            tempProfile.dietPreference = diet
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: diet.badgeIcon)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(isSelected ? AppTheme.primary : AppTheme.textSecondary)

                                Text(diet.rawValue)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(isSelected ? AppTheme.primary : AppTheme.textPrimary)

                                Spacer()

                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(AppTheme.primary)
                                }
                            }
                            .padding(12)
                            .background(isSelected ? AppTheme.primary.opacity(0.1) : AppTheme.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Name: \(tempProfile.displayName)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Stepper("Age: \(tempProfile.age)", value: $tempProfile.age, in: 12...100)
                    .font(.system(size: 14, weight: .semibold))

                Stepper("Height: \(Int(tempProfile.heightCm)) cm", value: $tempProfile.heightCm, in: 100...220, step: 1)
                    .font(.system(size: 14, weight: .semibold))

                Stepper("Weight: \(Int(tempProfile.weightKg)) kg", value: $tempProfile.weightKg, in: 30...200, step: 1)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(AppSpacing.md)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )
        }
    }

    private var defaultInfoView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(sheet.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text("SmartCery protects your health & dietary preferences locally on device. Chef Zest AI continuously calculates your macros, targets, and pantry freshness.")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(4)
        }
        .padding(AppSpacing.md)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
    }
}
