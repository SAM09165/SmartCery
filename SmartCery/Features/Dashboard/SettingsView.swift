import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: AppStore
    @State private var notificationsEnabled = true
    @State private var expiryAlertsEnabled = true
    @State private var mealPlanRemindersEnabled = false
    @State private var selectedSheet: MoreSheet?

    private let stats = [
        MoreStat(title: "Orders", value: "12", iconName: "bag.fill"),
        MoreStat(title: "Saved", value: "$84", iconName: "leaf.fill"),
        MoreStat(title: "Alerts", value: "3", iconName: "bell.badge.fill")
    ]

    private let orders = [
        OrderHistoryItem(number: "#SC-1042", status: "Arriving today", date: "Jul 25", total: "$28.42", itemCount: 6),
        OrderHistoryItem(number: "#SC-1038", status: "Delivered", date: "Jul 22", total: "$41.16", itemCount: 9),
        OrderHistoryItem(number: "#SC-1031", status: "Delivered", date: "Jul 18", total: "$19.74", itemCount: 4)
    ]

    var body: some View {
        ZStack {
            AppTheme.softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    profileCard
                    statsRow
                    orderHistorySection
                    preferencesSection
                    appOptionsSection
                    supportSection
                    signOutButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTopBar(
                    title: "More",
                    subtitle: "Profile, orders, preferences"
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
        .sheet(item: $selectedSheet) { sheet in
            MoreDetailSheet(sheet: sheet)
        }
    }

    private var profileCard: some View {
        HStack(spacing: 14) {
                Text(initials)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AppTheme.cream)
                .frame(width: 58, height: 58)
                .background(AppTheme.basilGreen, in: Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(store.profile?.displayName.capitalized ?? "Kitchen chef")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen)

                Text(store.profile?.email ?? "Offline kitchen")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.basilGreen.opacity(0.62))

                Text("SmartCery Plus · Home delivery")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.zestOrange)
            }

            Spacer(minLength: 0)

            Button {
                selectedSheet = .profile
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.cream, in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            ForEach(stats) { stat in
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: stat.iconName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppTheme.zestOrange)

                    Text(stat.value)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen)

                    Text(stat.title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.basilGreen.opacity(0.58))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(AppTheme.cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    private var orderHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Order history")

            VStack(spacing: 10) {
                ForEach(orders) { order in
                    Button {
                        selectedSheet = .order(order)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: order.status == "Delivered" ? "checkmark.seal.fill" : "truck.box.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(AppTheme.zestOrange)
                                .frame(width: 38, height: 38)
                                .background(AppTheme.cream, in: Circle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(order.number)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(AppTheme.basilGreen)

                                Text("\(order.status) · \(order.date) · \(order.itemCount) items")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(AppTheme.basilGreen.opacity(0.62))
                            }

                            Spacer(minLength: 0)

                            Text(order.total)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppTheme.basilGreen)
                        }
                        .padding(14)
                        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Preferences")

            VStack(spacing: 0) {
                preferenceToggle("Push notifications", iconName: "bell.fill", isOn: $notificationsEnabled)
                Divider().padding(.leading, 52)
                preferenceToggle("Expiry alerts", iconName: "clock.badge.exclamationmark.fill", isOn: $expiryAlertsEnabled)
                Divider().padding(.leading, 52)
                preferenceToggle("Meal plan reminders", iconName: "calendar.badge.clock", isOn: $mealPlanRemindersEnabled)
            }
            .padding(.vertical, 4)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private func preferenceToggle(_ title: String, iconName: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppTheme.zestOrange)
                .frame(width: 36, height: 36)
                .background(AppTheme.cream, in: Circle())

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppTheme.basilGreen)

            Spacer(minLength: 0)

            Toggle(title, isOn: isOn)
                .labelsHidden()
                .tint(AppTheme.zestOrange)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var appOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("App options")

            VStack(spacing: 10) {
                optionRow("Delivery addresses", subtitle: "Home · Work", iconName: "house.fill", sheet: .addresses)
                optionRow("Payment methods", subtitle: "Visa ending 4242", iconName: "creditcard.fill", sheet: .payments)
                optionRow("Diet and allergens", subtitle: "Vegetarian · Nut-free alerts", iconName: "person.crop.circle.badge.exclamationmark", sheet: .diet)
                optionRow("Privacy and data", subtitle: "Manage saved pantry and order data", iconName: "lock.shield.fill", sheet: .privacy)
            }
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Support")

            VStack(spacing: 10) {
                optionRow("Help center", subtitle: "Orders, refunds, pantry help", iconName: "questionmark.circle.fill", sheet: .help)
                optionRow("Contact SmartCery", subtitle: "Chat support available", iconName: "message.fill", sheet: .contact)
            }
        }
    }

    private func optionRow(_ title: String, subtitle: String, iconName: String, sheet: MoreSheet) -> some View {
        Button {
            selectedSheet = sheet
        } label: {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppTheme.zestOrange)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.cream, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(AppTheme.basilGreen.opacity(0.62))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen.opacity(0.38))
            }
            .padding(14)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var signOutButton: some View {
        Button {
            store.signOut()
            UserDefaults.standard.set(false, forKey: "smartcery.has-profile")
            router.destination = .auth
        } label: {
            Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var initials: String {
        let words = (store.profile?.displayName ?? "Kitchen Chef").split(separator: " ")
        return words.prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(AppTheme.basilGreen)
    }
}

private struct MoreStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let iconName: String
}

private struct OrderHistoryItem: Identifiable, Hashable {
    let id = UUID()
    let number: String
    let status: String
    let date: String
    let total: String
    let itemCount: Int
}

private enum MoreSheet: Identifiable {
    case profile
    case order(OrderHistoryItem)
    case addresses
    case payments
    case diet
    case privacy
    case help
    case contact
    case signOut

    var id: String {
        switch self {
        case .profile:
            return "profile"
        case .order(let order):
            return order.number
        case .addresses:
            return "addresses"
        case .payments:
            return "payments"
        case .diet:
            return "diet"
        case .privacy:
            return "privacy"
        case .help:
            return "help"
        case .contact:
            return "contact"
        case .signOut:
            return "signOut"
        }
    }

    var title: String {
        switch self {
        case .profile:
            return "Profile"
        case .order(let order):
            return order.number
        case .addresses:
            return "Delivery Addresses"
        case .payments:
            return "Payment Methods"
        case .diet:
            return "Diet and Allergens"
        case .privacy:
            return "Privacy and Data"
        case .help:
            return "Help Center"
        case .contact:
            return "Contact SmartCery"
        case .signOut:
            return "Sign Out"
        }
    }

    var message: String {
        switch self {
        case .profile:
            return "Manage your name, email, membership, and delivery profile."
        case .order(let order):
            return "\(order.status) on \(order.date). \(order.itemCount) items totaling \(order.total)."
        case .addresses:
            return "Home and work delivery addresses can be managed here."
        case .payments:
            return "Saved cards, wallet options, and billing preferences appear here."
        case .diet:
            return "Set dietary preferences and allergen warnings used by Chef Zest and Market."
        case .privacy:
            return "Review saved pantry, meal planner, order, and profile data."
        case .help:
            return "Find help for grocery orders, refunds, substitutions, and pantry tracking."
        case .contact:
            return "Chat support and email support options appear here."
        case .signOut:
            return "This is a mock sign-out action until real authentication is connected."
        }
    }

    var iconName: String {
        switch self {
        case .profile:
            return "person.crop.circle.fill"
        case .order:
            return "bag.fill"
        case .addresses:
            return "house.fill"
        case .payments:
            return "creditcard.fill"
        case .diet:
            return "leaf.fill"
        case .privacy:
            return "lock.shield.fill"
        case .help:
            return "questionmark.circle.fill"
        case .contact:
            return "message.fill"
        case .signOut:
            return "rectangle.portrait.and.arrow.right"
        }
    }
}

private struct MoreDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let sheet: MoreSheet

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.softCream.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    Image(systemName: sheet.iconName)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(AppTheme.zestOrange)
                        .frame(width: 64, height: 64)
                        .background(AppTheme.cream, in: Circle())

                    Text(sheet.title)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen)

                    Text(sheet.message)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(AppTheme.basilGreen.opacity(0.68))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            }
            .navigationTitle(sheet.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(AppRouter())
    .environmentObject(AppStore())
}
