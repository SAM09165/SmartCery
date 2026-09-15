import SwiftUI
import Combine

struct MealPlanDay: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let date: Date
    let weekday: String
    let dateLabel: String
    let focus: String
    var meals: [PlannedMeal]
}

struct PlannedMeal: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    let title: String
    let type: String
    let time: String
    let cookTime: String
    let calories: Int
    let protein: Int
    let usesPantry: [String]
    let missingItems: [String]
    let iconName: String
}

@MainActor
final class MealPlannerViewModel: ObservableObject {
    @Published var selectedDayID: UUID
    @Published var days: [MealPlanDay] {
        didSet {
            saveDays()
        }
    }

    private static let storageKey = "smartcery.meal-planner.days.v1"

    init() {
        let loadedDays = Self.loadSavedDays()
        if let firstLoaded = loadedDays.first, Calendar.current.isDateInToday(firstLoaded.date) {
            self.days = loadedDays
            self.selectedDayID = loadedDays[0].id
        } else {
            let freshDays = Self.generateDays()
            self.days = freshDays
            self.selectedDayID = freshDays[0].id
        }
    }

    var selectedDay: MealPlanDay {
        days.first { $0.id == selectedDayID } ?? (days.first ?? Self.generateDays()[0])
    }

    var dailyCalories: Int {
        selectedDay.meals.reduce(0) { $0 + $1.calories }
    }

    var dailyProtein: Int {
        selectedDay.meals.reduce(0) { $0 + $1.protein }
    }

    var missingItems: [String] {
        Array(Set(selectedDay.meals.flatMap(\.missingItems))).sorted()
    }

    var pantryItemCount: Int {
        Set(selectedDay.meals.flatMap(\.usesPantry)).count
    }

    func addMeal(
        title: String,
        type: String,
        time: String,
        cookTime: String,
        calories: Int,
        protein: Int,
        usesPantry: [String],
        missingItems: [String]
    ) {
        guard let selectedIndex = days.firstIndex(where: { $0.id == selectedDayID }) else {
            return
        }

        let meal = PlannedMeal(
            title: title,
            type: type,
            time: time,
            cookTime: cookTime,
            calories: calories,
            protein: protein,
            usesPantry: usesPantry,
            missingItems: missingItems,
            iconName: iconName(for: type)
        )

        days[selectedIndex].meals.append(meal)
    }

    func deleteMeal(id: UUID) {
        guard let selectedIndex = days.firstIndex(where: { $0.id == selectedDayID }) else { return }
        days[selectedIndex].meals.removeAll { $0.id == id }
    }

    private func iconName(for mealType: String) -> String {
        switch mealType {
        case "Breakfast":
            return "sunrise.fill"
        case "Lunch":
            return "leaf.fill"
        case "Snack":
            return "takeoutbag.and.cup.and.straw.fill"
        default:
            return "moon.stars.fill"
        }
    }

    private func saveDays() {
        if let encoded = try? JSONEncoder().encode(days) {
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
        }
    }

    private static func loadSavedDays() -> [MealPlanDay] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([MealPlanDay].self, from: data) else {
            return []
        }
        return decoded
    }

    static func generateDays() -> [MealPlanDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"

        var result: [MealPlanDay] = []
        let focuses = [
            "High protein, low waste",
            "Quick & fresh meals",
            "Use expiring pantry items",
            "Balanced comfort food",
            "Market prep & batch cooking",
            "Weekend light reset",
            "Pantry favorite recipes"
        ]

        let sampleMealsToday = [
            PlannedMeal(
                title: "Spinach Paneer Wrap",
                type: "Breakfast",
                time: "8:00 AM",
                cookTime: "15 min",
                calories: 420,
                protein: 24,
                usesPantry: ["Paneer", "Spinach", "Tortilla"],
                missingItems: ["Mint chutney"],
                iconName: "sunrise.fill"
            ),
            PlannedMeal(
                title: "Chickpea Power Bowl",
                type: "Lunch",
                time: "1:00 PM",
                cookTime: "20 min",
                calories: 560,
                protein: 28,
                usesPantry: ["Chickpeas", "Rice", "Cucumber"],
                missingItems: [],
                iconName: "leaf.fill"
            ),
            PlannedMeal(
                title: "Tomato Lentil Soup",
                type: "Dinner",
                time: "7:30 PM",
                cookTime: "25 min",
                calories: 390,
                protein: 21,
                usesPantry: ["Lentils", "Tomatoes", "Carrots"],
                missingItems: ["Sourdough"],
                iconName: "moon.stars.fill"
            )
        ]

        let sampleMealsTomorrow = [
            PlannedMeal(
                title: "Berry Oats",
                type: "Breakfast",
                time: "8:15 AM",
                cookTime: "10 min",
                calories: 360,
                protein: 16,
                usesPantry: ["Oats", "Milk"],
                missingItems: ["Blueberries"],
                iconName: "sunrise.fill"
            ),
            PlannedMeal(
                title: "Veggie Fried Rice",
                type: "Lunch",
                time: "12:45 PM",
                cookTime: "18 min",
                calories: 520,
                protein: 18,
                usesPantry: ["Rice", "Eggs", "Peas"],
                missingItems: [],
                iconName: "leaf.fill"
            )
        ]

        for offset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            let isToday = calendar.isDateInToday(date)
            let weekday = isToday ? "Today" : dateFormatter.string(from: date)
            let dateLabel = dayFormatter.string(from: date)
            let focus = focuses[offset % focuses.count]

            var initialMeals: [PlannedMeal] = []
            if offset == 0 {
                initialMeals = sampleMealsToday
            } else if offset == 1 {
                initialMeals = sampleMealsTomorrow
            }

            result.append(MealPlanDay(
                date: date,
                weekday: weekday,
                dateLabel: dateLabel,
                focus: focus,
                meals: initialMeals
            ))
        }

        return result
    }
}
