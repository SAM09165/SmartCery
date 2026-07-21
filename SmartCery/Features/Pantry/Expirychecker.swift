import Foundation

enum ExpiryStatus {
    case expired
    case expiringSoon(daysLeft: Int)
    case fresh
}

// Pure date-comparison logic — counting days between two dates, no formulas.
enum Expirychecker {
    static func status(for date: Date?, referenceDate: Date = Date()) -> ExpiryStatus {
        guard let date else { return .fresh }

        let calendar = Calendar.current
        let startOfReference = calendar.startOfDay(for: referenceDate)
        let startOfExpiry = calendar.startOfDay(for: date)
        let daysLeft = calendar.dateComponents([.day], from: startOfReference, to: startOfExpiry).day ?? 0

        if daysLeft < 0 {
            return .expired
        } else if daysLeft <= 3 {
            return .expiringSoon(daysLeft: daysLeft)
        } else {
            return .fresh
        }
    }
}
