import SwiftUI

struct PantryView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: AppStore
    @State private var showingAddSheet: Bool = false

    var body: some View {
        ZStack {
            AppTheme.softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    if !needsAttention.isEmpty {
                        sectionHeader("Needs attention")
                        VStack(spacing: 10) {
                            ForEach(needsAttention) { entry in
                                pantryRow(entry)
                            }
                        }
                    }

                    sectionHeader(needsAttention.isEmpty ? "Your pantry" : "Fresh & stocked")
                    if freshItems.isEmpty && needsAttention.isEmpty {
                        ContentUnavailableView("Your pantry is empty", systemImage: "cabinet.fill", description: Text("Tap + to add the food you already have."))
                    } else {
                        VStack(spacing: 10) {
                            ForEach(freshItems) { entry in
                                pantryRow(entry)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTopBar(
                    title: "Pantry",
                    subtitle: subtitleLine,
                    trailingIcon: "plus",
                    onTrailingTap: { showingAddSheet = true }
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
        // PantrySeedView in 'addItems' mode for adding new pantry items.
        .sheet(isPresented: $showingAddSheet) {
            PantrySeedView(mode: .addItems)
                .environmentObject(router)
                .environmentObject(store)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(AppTheme.basilGreen)
    }

    private var needsAttention: [PantryItem] { store.pantry.filter { if case .fresh = Expirychecker.status(for: $0.expiryDate) { return false }; return true } }
    private var freshItems: [PantryItem] { store.pantry.filter { if case .fresh = Expirychecker.status(for: $0.expiryDate) { return true }; return false } }
    private var subtitleLine: String { "\(store.pantry.count) item\(store.pantry.count == 1 ? "" : "s") · \(needsAttention.count) need attention" }

    private func pantryRow(_ entry: PantryItem) -> some View {
        let status = Expirychecker.status(for: entry.expiryDate)

        return HStack(spacing: 14) {
            Image(systemName: entry.iconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.zestOrange)
                .frame(width: 40, height: 40)
                .background(AppTheme.cream, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen)

                Text(entry.quantity)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(AppTheme.basilGreen.opacity(0.6))
            }

            Spacer()

            statusBadge(status)
        }
        .padding(14)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func statusBadge(_ status: ExpiryStatus) -> some View {
        let text: String
        let color: Color

        switch status {
        case .expired:
            text = "Expired"
            color = .red
        case .expiringSoon(let daysLeft):
            text = daysLeft == 0 ? "Today" : "\(daysLeft)d left"
            color = AppTheme.zestOrange
        case .fresh:
            text = "Fresh"
            color = AppTheme.basilGreen
        }

        return Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12), in: Capsule())
    }
}

#Preview {
    PantryView()
        .environmentObject(AppRouter()).environmentObject(AppStore())
}
