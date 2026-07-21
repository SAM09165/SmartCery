import Foundation

struct PantryEntry: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: String
    let quantity: String // display string, e.g. "1 L", "6 pcs" — no unit math yet
    let expiryDate: Date?
    let iconName: String
}

enum PantryCatalog {
    static let sample: [PantryEntry] = {
        let calendar = Calendar.current
        let today = Date()

        func daysFromNow(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: days, to: today) ?? today
        }

        return [
            PantryEntry(name: "Whole Milk", category: "Dairy", quantity: "1 L", expiryDate: daysFromNow(1), iconName: "drop.fill"),
            PantryEntry(name: "Greek Yogurt", category: "Dairy", quantity: "2 cups", expiryDate: daysFromNow(-1), iconName: "cup.and.saucer.fill"),
            PantryEntry(name: "Large Eggs", category: "Dairy", quantity: "6 pcs", expiryDate: daysFromNow(5), iconName: "oval.fill"),
            PantryEntry(name: "Spinach", category: "Produce", quantity: "1 bunch", expiryDate: daysFromNow(2), iconName: "leaf.fill"),
            PantryEntry(name: "Bananas", category: "Produce", quantity: "6 pcs", expiryDate: daysFromNow(3), iconName: "leaf.fill"),
            PantryEntry(name: "Basmati Rice", category: "Pantry", quantity: "5 kg", expiryDate: daysFromNow(180), iconName: "takeoutbag.and.cup.and.straw.fill"),
            PantryEntry(name: "Olive Oil", category: "Pantry", quantity: "1 bottle", expiryDate: daysFromNow(220), iconName: "drop.triangle.fill")
        ]
    }()
}
