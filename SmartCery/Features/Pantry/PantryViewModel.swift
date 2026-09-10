import Foundation
import Combine

@MainActor
final class PantryViewModel: ObservableObject {
    let entries: [PantryEntry] = PantryCatalog.sample

    var needsAttention: [PantryEntry] {
        entries.filter {
            switch Expirychecker.status(for: $0.expiryDate) {
            case .expired, .expiringSoon:
                return true
            case .fresh:
                return false
            }
        }
    }

    var freshItems: [PantryEntry] {
        entries.filter {
            if case .fresh = Expirychecker.status(for: $0.expiryDate) { return true }
            return false
        }
    }

    var subtitleLine: String {
        let attentionCount = needsAttention.count
        return attentionCount == 0
            ? "\(entries.count) items stocked — nothing urgent."
            : "\(entries.count) items · \(attentionCount) need attention"
    }
}
