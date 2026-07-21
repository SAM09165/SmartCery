import SwiftUI
internal import Combine

struct MealPlanDay: Identifiable, Hashable {
    let id = UUID()
    let weekday: String
    let dateLabel: String
    let focus: String
    var meals: [PlannedMeal]
}

struct PlannedMeal: Identifiable, Hashable {
    let id = UUID()
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
    @Published var selectedDayID: MealPlanDay.ID
    @Published var days: [MealPlanDay]

    init() {
        let sampleDays = [
            MealPlanDay(
                weekday: "Mon",
                dateLabel: "22",
                focus: "High protein, low waste",
                meals: [
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
            ),
            MealPlanDay(
                weekday: "Tue",
                dateLabel: "23",
                focus: "Quick meals",
                meals: [
                    PlannedMeal(title: "Berry Oats", type: "Breakfast", time: "8:15 AM", cookTime: "10 min", calories: 360, protein: 16, usesPantry: ["Oats", "Milk"], missingItems: ["Blueberries"], iconName: "sunrise.fill"),
                    PlannedMeal(title: "Veggie Fried Rice", type: "Lunch", time: "12:45 PM", cookTime: "18 min", calories: 520, protein: 18, usesPantry: ["Rice", "Eggs", "Peas"], missingItems: [], iconName: "leaf.fill"),
                    PlannedMeal(title: "Lemon Herb Pasta", type: "Dinner", time: "8:00 PM", cookTime: "22 min", calories: 610, protein: 19, usesPantry: ["Pasta", "Garlic"], missingItems: ["Parsley", "Lemon"], iconName: "moon.stars.fill")
                ]
            ),
            MealPlanDay(
                weekday: "Wed",
                dateLabel: "24",
                focus: "Use fresh produce",
                meals: [
                    PlannedMeal(title: "Masala Omelette", type: "Breakfast", time: "8:00 AM", cookTime: "12 min", calories: 330, protein: 22, usesPantry: ["Eggs", "Onion"], missingItems: [], iconName: "sunrise.fill"),
                    PlannedMeal(title: "Cucumber Dal Bowl", type: "Lunch", time: "1:15 PM", cookTime: "20 min", calories: 490, protein: 25, usesPantry: ["Dal", "Rice", "Cucumber"], missingItems: [], iconName: "leaf.fill"),
                    PlannedMeal(title: "Grilled Paneer Salad", type: "Dinner", time: "7:45 PM", cookTime: "18 min", calories: 450, protein: 31, usesPantry: ["Paneer", "Lettuce"], missingItems: ["Cherry tomatoes"], iconName: "moon.stars.fill")
                ]
            ),
            MealPlanDay(weekday: "Thu", dateLabel: "25", focus: "Balanced comfort", meals: []),
            MealPlanDay(weekday: "Fri", dateLabel: "26", focus: "Market prep", meals: []),
            MealPlanDay(weekday: "Sat", dateLabel: "27", focus: "Weekend batch cook", meals: []),
            MealPlanDay(weekday: "Sun", dateLabel: "28", focus: "Light reset", meals: [])
        ]

        days = sampleDays
        selectedDayID = sampleDays[0].id
    }

    var selectedDay: MealPlanDay {
        days.first { $0.id == selectedDayID } ?? days[0]
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
}
