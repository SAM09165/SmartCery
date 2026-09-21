import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func syncExpiryNotifications(for items: [PantryItem]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        for item in items {
            scheduleExpiryNotification(for: item)
        }
    }

    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func scheduleExpiryNotification(for item: PantryItem) {
        guard let expiryDate = item.expiryDate, expiryDate > Date() else { return }

        let calendar = Calendar.current
        let now = Date()

        // 2 days prior to expiry
        let advanceDate = calendar.date(byAdding: .day, value: -2, to: expiryDate) ?? expiryDate

        let isUrgent: Bool
        let triggerDate: Date

        if advanceDate > now {
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: advanceDate)
            dateComponents.hour = 8
            dateComponents.minute = 0
            triggerDate = calendar.date(from: dateComponents) ?? advanceDate
            isUrgent = false
        } else {
            // Expiring within 48 hours (today or tomorrow) - schedule an urgent reminder
            triggerDate = now.addingTimeInterval(600) // 10 minutes from now
            isUrgent = true
        }

        guard triggerDate > now else { return }

        let content = UNMutableNotificationContent()
        if isUrgent {
            content.title = "🚨 Urgent Expiry Alert: \(item.name)"
            content.body = "Your \(item.name) (\(item.quantity)) expires very soon! Cook or rescue it today with Chef Zest."
        } else {
            content.title = "⚠️ Expiry Alert: \(item.name)"
            content.body = "Your \(item.name) (\(item.quantity)) is expiring soon. Open SmartCery for zero-waste Chef Zest recipes!"
        }
        content.sound = .default
        content.badge = 1

        let trigger: UNNotificationTrigger
        if isUrgent {
            let timeInterval = max(60, triggerDate.timeIntervalSince(now))
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        } else {
            let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        }

        let request = UNNotificationRequest(
            identifier: "expiry-\(item.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule notification for \(item.name): \(error.localizedDescription)")
            }
        }
    }

    func cancelExpiryNotification(for id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["expiry-\(id.uuidString)"])
    }
}
