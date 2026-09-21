//
//  SettingsView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var sessionManager: SessionManager

    @AppStorage("smartcery.settings.notifications-enabled") private var notificationsEnabled = true
    @AppStorage("smartcery.settings.expiry-alerts-enabled") private var expiryAlertsEnabled = true
    @AppStorage("smartcery.settings.meal-plan-reminders-enabled") private var mealPlanRemindersEnabled = false
    @State private var selectedSheet: MoreSheet?
    @State private var isScrolled = false

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange
    private let cream = AppTheme.cream
    private let softCream = AppTheme.softCream
    private let elevatedSurface = AppTheme.elevatedSurface

    private var profile: UserProfile {
        store.profile ?? UserProfile()
    }

    private var stats: [MoreStat] {
        [
            MoreStat(title: "Target Cal", value: "\(profile.calculatedTargetCalories)", iconName: "flame.fill"),
            MoreStat(title: "Protein", value: "\(profile.calculatedTargetProtein)g", iconName: "bolt.heart.fill"),
            MoreStat(title: "Strict Diet", value: profile.dietPreference.rawValue.replacingOccurrences(of: "Strict ", with: ""), iconName: "leaf.fill")
        ]
    }

    var body: some View {
        ZStack {
            softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Geometry Reader for Scroll Offset Tracking
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("settingsScroll")).minY
                        )
                    }
                    .frame(height: 0)

                    // 1. PROFILE HERO CARD
                    profileCard

                    // 2. HEALTH & MACRO STATS ROW
                    statsRow

                    // 3. PREFERENCES SECTION
                    preferencesSection

                    // 4. APP OPTIONS SECTION
                    appOptionsSection

                    // 5. SUPPORT SECTION
                    supportSection

                    // 6. SIGN OUT BUTTON
                    signOutButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
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
                    title: "Settings & Health Profile",
                    subtitle: "Manage diet rules, health goals & metrics",
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

    // MARK: - 1. PROFILE HERO CARD
    private var profileCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(basilGreen)
                    .frame(width: 58, height: 58)

                Text(initials)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(cream)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(store.profile?.displayName.capitalized ?? "Kitchen Hero")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(basilGreen)

                HStack(spacing: 6) {
                    Image(systemName: profile.dietPreference.badgeIcon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(profile.dietPreference.isStrictVeg ? Color.green : zestOrange)

                    Text(profile.dietPreference.rawValue)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(profile.dietPreference.isStrictVeg ? Color.green : zestOrange)
                }

                Text("Height: \(Int(profile.heightCm))cm • Weight: \(Int(profile.weightKg))kg • Age: \(profile.age)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(basilGreen.opacity(0.65))
            }

            Spacer(minLength: 0)

            Button {
                HapticManager.impact(.medium)
                selectedSheet = .profile
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(basilGreen)
                    .frame(width: 36, height: 36)
                    .background(cream, in: Circle() )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.8), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    // MARK: - 2. STATS ROW
    private var statsRow: some View {
        HStack(spacing: 10) {
            ForEach(stats) { stat in
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: stat.iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(zestOrange)

                    Text(stat.value)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(basilGreen)
                        .lineLimit(1)

                    Text(stat.title)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(basilGreen.opacity(0.6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    // MARK: - 3. PREFERENCES SECTION
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Preferences")

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
                Divider().padding(.leading, 52)
                preferenceToggle("Expiry Alerts", iconName: "clock.badge.exclamationmark.fill", isOn: $expiryAlertsEnabled)
                    .onChange(of: expiryAlertsEnabled) { _, enabled in
                        if !enabled {
                            NotificationService.shared.clearAllNotifications()
                        } else if notificationsEnabled {
                            NotificationService.shared.syncExpiryNotifications(for: store.pantry)
                        }
                    }
                Divider().padding(.leading, 52)
                preferenceToggle("Meal Plan Reminders", iconName: "calendar.badge.clock", isOn: $mealPlanRemindersEnabled)
            }
            .padding(.vertical, 4)
            .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
            )
        }
    }

    private func preferenceToggle(_ title: String, iconName: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(zestOrange)
                .frame(width: 36, height: 36)
                .background(cream, in: Circle())

            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(basilGreen)

            Spacer(minLength: 0)

            Toggle(title, isOn: isOn)
                .labelsHidden()
                .tint(zestOrange)
                .onChange(of: isOn.wrappedValue) { _, _ in
                    HapticManager.impact(.light)
                }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - 4. APP OPTIONS SECTION
    private var appOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Health & Diet Options")

            VStack(spacing: 10) {
                optionRow("Diet & Strict Preference", subtitle: profile.dietPreference.rawValue, iconName: "leaf.fill", sheet: .diet)
                optionRow("Edit Personal Health Metrics", subtitle: "Height, Weight, Workout level", iconName: "figure.walk", sheet: .profile)
                optionRow("Privacy & Data", subtitle: "Manage saved pantry and profile data", iconName: "lock.shield.fill", sheet: .privacy)
            }
        }
    }

    // MARK: - 5. SUPPORT SECTION
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Support & Help")

            VStack(spacing: 10) {
                optionRow("Chef Zest Guidance", subtitle: "How BMR, TDEE, & Veg rules work", iconName: "questionmark.circle.fill", sheet: .help)
                optionRow("Contact Support", subtitle: "Send feedback or questions", iconName: "message.fill", sheet: .contact)
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
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(basilGreen)
                    .frame(width: 38, height: 38)
                    .background(cream, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(basilGreen)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(basilGreen.opacity(0.6))
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(basilGreen.opacity(0.35))
            }
            .padding(14)
            .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 6. SIGN OUT BUTTON
    private var signOutButton: some View {
        Button {
            HapticManager.impact(.heavy)
            store.signOut()
            sessionManager.signOut()
            router.destination = .auth
        } label: {
            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var initials: String {
        let words = (store.profile?.displayName ?? "Kitchen Hero").split(separator: " ")
        return words.prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(basilGreen)
    }
}

private struct MoreStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let iconName: String
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
                AppTheme.softCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        if sheet == .profile || sheet == .diet {
                            editableProfileForm
                        } else {
                            defaultInfoView
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(sheet.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if sheet == .profile || sheet == .diet {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            store.setProfile(tempProfile)
                            dismiss()
                        }
                        .font(.system(size: 15, weight: .bold, design: .rounded))
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
        VStack(alignment: .leading, spacing: 18) {
            Text("Edit Health Profile & Strict Diet")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.basilGreen)

            VStack(alignment: .leading, spacing: 12) {
                Text("Dietary Preference")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.basilGreen)

                Picker("Diet Preference", selection: $tempProfile.dietPreference) {
                    ForEach(DietaryPreference.allCases, id: \.self) { diet in
                        Text(diet.rawValue).tag(diet)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Name: \(tempProfile.displayName)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.basilGreen)

                Stepper("Age: \(tempProfile.age)", value: $tempProfile.age, in: 12...100)
                    .font(.system(size: 14, weight: .semibold))

                Stepper("Height: \(Int(tempProfile.heightCm)) cm", value: $tempProfile.heightCm, in: 100...220, step: 1)
                    .font(.system(size: 14, weight: .semibold))

                Stepper("Weight: \(Int(tempProfile.weightKg)) kg", value: $tempProfile.weightKg, in: 30...200, step: 1)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(14)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var defaultInfoView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(sheet.title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.basilGreen)

            Text("SmartCery protects your health & dietary preferences locally on device. Chef Zest AI continuously calculates your macros and pantry freshness.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppTheme.basilGreen.opacity(0.7))
                .lineSpacing(4)
        }
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppRouter())
        .environmentObject(AppStore())
        .environmentObject(SessionManager())
}
