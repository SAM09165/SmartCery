import SwiftUI

struct ExpiryTrackerView: View {
    @StateObject private var viewModel = ExpiryTrackerViewModel()
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ZStack {
            AppTheme.softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    rescueCard
                    filterControl
                    statusSummary
                    expiryList
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTopBar(
                    title: "Expiry Tracker",
                    subtitle: viewModel.subtitleLine,
                    trailingIcon: "bell.badge.fill"
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
        .task { viewModel.replaceItems(store.pantry) }
        .onChange(of: store.pantry) { _, items in viewModel.replaceItems(items) }
    }

    private var rescueCard: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "clock.badge.exclamationmark.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.zestOrange)
                .frame(width: 42, height: 42)
                .background(AppTheme.cream, in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(rescueTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen)
                    .fixedSize(horizontal: false, vertical: true)

                Text(rescueSubtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppTheme.basilGreen.opacity(0.66))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var rescueTitle: String {
        guard let item = viewModel.nextRescueItem else {
            return "Your pantry is clear right now."
        }

        return "Rescue \(item.entry.name)"
    }

    private var rescueSubtitle: String {
        guard let item = viewModel.nextRescueItem else {
            return "Nothing is expired or close to expiring in this filter."
        }

        return "\(item.entry.quantity) · \(item.statusTitle). \(item.actionHint)"
    }

    private var filterControl: some View {
        Picker("Expiry filter", selection: $viewModel.selectedFilter) {
            ForEach(ExpiryFilter.allCases) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }

    private var statusSummary: some View {
        HStack(spacing: 10) {
            summaryTile(
                iconName: "xmark.octagon.fill",
                value: "\(viewModel.expiredCount)",
                label: "Expired",
                color: .red
            )
            summaryTile(
                iconName: "exclamationmark.triangle.fill",
                value: "\(viewModel.expiringSoonCount)",
                label: "Soon",
                color: AppTheme.zestOrange
            )
            summaryTile(
                iconName: "checkmark.seal.fill",
                value: "\(viewModel.freshCount)",
                label: "Fresh",
                color: AppTheme.basilGreen
            )
        }
    }

    private func summaryTile(iconName: String, value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.basilGreen)
                .lineLimit(1)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppTheme.basilGreen.opacity(0.58))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var expiryList: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("\(viewModel.selectedFilter.rawValue) items")

            if viewModel.visibleItems.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.visibleItems) { item in
                        expiryRow(item)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(AppTheme.basilGreen)

            Text("No items here")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.basilGreen)

            Text("Switch filters to review the rest of your pantry.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppTheme.basilGreen.opacity(0.64))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func expiryRow(_ item: ExpiryTrackerItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: item.entry.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(statusColor(for: item.status))
                    .frame(width: 42, height: 42)
                    .background(AppTheme.cream, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.entry.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(item.entry.quantity) · \(item.entry.category)")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AppTheme.basilGreen.opacity(0.62))

                    Text(item.actionHint)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AppTheme.basilGreen.opacity(0.62))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                statusBadge(item.statusTitle, status: item.status)
            }

            HStack(spacing: 10) {
                Button {
                    store.removePantryItem(item.id)
                } label: {
                    Label("Used", systemImage: "checkmark")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(AppTheme.cream)
                        .background(AppTheme.basilGreen, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    store.extendPantryItem(item.id)
                } label: {
                    Label("+3d", systemImage: "calendar.badge.plus")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(AppTheme.basilGreen)
                        .background(AppTheme.cream, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func statusBadge(_ text: String, status: ExpiryStatus) -> some View {
        let color = statusColor(for: status)

        return Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12), in: Capsule())
            .lineLimit(1)
    }

    private func statusColor(for status: ExpiryStatus) -> Color {
        switch status {
        case .expired:
            return .red
        case .expiringSoon:
            return AppTheme.zestOrange
        case .fresh:
            return AppTheme.basilGreen
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(AppTheme.basilGreen)
    }
}

#Preview {
    ExpiryTrackerView()
        .environmentObject(AppStore())
}
