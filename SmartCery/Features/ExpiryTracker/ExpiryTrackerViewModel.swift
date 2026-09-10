import Foundation
import Combine

enum ExpiryFilter: String, CaseIterable, Identifiable {
    case urgent = "Urgent"
    case thisWeek = "This Week"
    case all = "All"

    var id: String { rawValue }
}

struct ExpiryTrackerItem: Identifiable {
    let id: PantryItem.ID
    let entry: PantryItem
    let daysLeft: Int?
    let status: ExpiryStatus

    var statusTitle: String {
        switch status {
        case .expired:
            return "Expired"
        case .expiringSoon(let daysLeft):
            return daysLeft == 0 ? "Expires today" : "\(daysLeft)d left"
        case .fresh:
            guard let daysLeft else { return "No date" }
            return "\(daysLeft)d left"
        }
    }

    var actionHint: String {
        switch status {
        case .expired:
            return "Check before using or remove from pantry."
        case .expiringSoon(let daysLeft):
            if daysLeft == 0 {
                return "Use today in a quick meal."
            }
            return "Plan this into the next \(daysLeft)d."
        case .fresh:
            return "Still fresh. No rush."
        }
    }
}

@MainActor
final class ExpiryTrackerViewModel: ObservableObject {
    @Published var items: [PantryItem]
    @Published var selectedFilter: ExpiryFilter = .urgent

    private let calendar = Calendar.current
    private let referenceDate: Date

    init(items: [PantryItem] = [], referenceDate: Date = Date()) {
        self.items = items
        self.referenceDate = referenceDate
    }

    var trackedItems: [ExpiryTrackerItem] {
        items
            .map(trackerItem(for:))
            .sorted { lhs, rhs in
                (lhs.daysLeft ?? Int.max) < (rhs.daysLeft ?? Int.max)
            }
    }

    var visibleItems: [ExpiryTrackerItem] {
        switch selectedFilter {
        case .urgent:
            return trackedItems.filter {
                if case .fresh = $0.status { return false }
                return true
            }
        case .thisWeek:
            return trackedItems.filter { ($0.daysLeft ?? Int.max) <= 7 }
        case .all:
            return trackedItems
        }
    }

    var expiredCount: Int {
        trackedItems.filter {
            if case .expired = $0.status { return true }
            return false
        }.count
    }

    var expiringSoonCount: Int {
        trackedItems.filter {
            if case .expiringSoon = $0.status { return true }
            return false
        }.count
    }

    var freshCount: Int {
        trackedItems.filter {
            if case .fresh = $0.status { return true }
            return false
        }.count
    }

    var subtitleLine: String {
        if expiredCount > 0 {
            return "\(expiredCount) expired · \(expiringSoonCount) expiring soon"
        }

        if expiringSoonCount > 0 {
            return "\(expiringSoonCount) items need a plan"
        }

        return "\(freshCount) fresh items tracked"
    }

    var nextRescueItem: ExpiryTrackerItem? {
        visibleItems.first
    }

    func markUsed(_ item: ExpiryTrackerItem) {
        items.removeAll { $0.id == item.id }
    }

    func extend(_ item: ExpiryTrackerItem, by days: Int = 3) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        let entry = items[index]
        let baseDate = entry.expiryDate ?? referenceDate
        let extendedDate = calendar.date(byAdding: .day, value: days, to: baseDate) ?? baseDate

        items[index].expiryDate = extendedDate
    }

    func replaceItems(_ items: [PantryItem]) { self.items = items }

    private func trackerItem(for entry: PantryItem) -> ExpiryTrackerItem {
        let daysLeft = entry.expiryDate.map { expiryDate in
            let start = calendar.startOfDay(for: referenceDate)
            let end = calendar.startOfDay(for: expiryDate)
            return calendar.dateComponents([.day], from: start, to: end).day ?? 0
        }

        return ExpiryTrackerItem(
            id: entry.id,
            entry: entry,
            daysLeft: daysLeft,
            status: Expirychecker.status(for: entry.expiryDate, referenceDate: referenceDate)
        )
    }
}
