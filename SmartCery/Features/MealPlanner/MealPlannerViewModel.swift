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
    var imageURL: String? = nil
}

struct ChatMessage: Identifiable, Hashable {
    var id: UUID = UUID()
    let text: String
    let isUser: Bool
}

@MainActor
final class MealPlannerViewModel: ObservableObject {
    @Published var selectedDayID: UUID
    @Published var targetCalories: Int = 2100
    @Published var targetProtein: Int = 135
    @Published var showingAddMealSheet: Bool = false
    @Published var chatInput: String = ""
    @Published var chatMessages: [ChatMessage] = [
        ChatMessage(text: "Namaste! I'm Chef Zest, your AI Dietitian. Ask me anything about your macros, daily calorie targets, or Indian pantry recipes!", isUser: false)
    ]
    @Published var days: [MealPlanDay] {
        didSet {
            saveDays()
        }
    }

    private static let storageKey = "smartcery.meal-planner.days.v1"

    init() {
        let loadedDays = Self.loadSavedDays()
        let activeDays = Self.reconcile(savedDays: loadedDays)
        self.days = activeDays
        self.selectedDayID = activeDays.first?.id ?? UUID()
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

    var calorieProgress: Double {
        min(Double(dailyCalories) / Double(targetCalories), 1.0)
    }

    var proteinProgress: Double {
        min(Double(dailyProtein) / Double(targetProtein), 1.0)
    }

    var missingItems: [String] {
        Array(Set(selectedDay.meals.flatMap(\.missingItems))).sorted()
    }

    var pantryItemCount: Int {
        Set(selectedDay.meals.flatMap(\.usesPantry)).count
    }

    func updateProfile(_ profile: UserProfile) {
        targetCalories = profile.calculatedTargetCalories
        targetProtein = profile.calculatedTargetProtein
    }

    func openAddMealSheet() {
        showingAddMealSheet = true
    }

    func sendChatMessage() {
        let trimmed = chatInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        chatMessages.append(ChatMessage(text: trimmed, isUser: true))
        chatInput = ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }
            let response = "Based on your current macro target (\(self.targetCalories) kcal, \(self.targetProtein)g protein), incorporating Paneer, Dal, or Tofu will perfectly balance your remaining goals!"
            self.chatMessages.append(ChatMessage(text: response, isUser: false))
        }
    }

    func addMeal(
        title: String,
        type: String,
        time: String = "1:00 PM",
        cookTime: String = "20 min",
        calories: Int,
        protein: Int,
        usesPantry: [String],
        missingItems: [String],
        imageURL: String? = nil
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
            iconName: iconName(for: type),
            imageURL: imageURL ?? RecipeImageCatalog.imageURL(for: title)
        )

        days[selectedIndex].meals.append(meal)
    }

    func deleteMeal(id: UUID) {
        guard let selectedIndex = days.firstIndex(where: { $0.id == selectedDayID }) else { return }
        days[selectedIndex].meals.removeAll { $0.id == id }
    }

    func autoBalanceDayWithAI(pantry: [PantryItem]) {
        let deficitProtein = max(targetProtein - dailyProtein, 20)
        let deficitCal = max(targetCalories - dailyCalories, 350)

        addMeal(
            title: "Chef Zest High-Protein Bowl",
            type: "Snack",
            time: "4:30 PM",
            cookTime: "10 min",
            calories: deficitCal,
            protein: deficitProtein,
            usesPantry: pantry.prefix(3).map(\.name),
            missingItems: []
        )
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

    /// Reconciles saved meal days on date turnover so future user meals are preserved
    static func reconcile(savedDays: [MealPlanDay]) -> [MealPlanDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"

        let focuses = [
            "High protein, low waste",
            "Quick & fresh meals",
            "Use expiring pantry items",
            "Balanced comfort food",
            "Market prep & batch cooking",
            "Weekend light reset",
            "Pantry favorite recipes"
        ]

        guard !savedDays.isEmpty else {
            return generateDays()
        }

        // Keep existing days that are today or in the future
        var validFutureDays: [MealPlanDay] = []
        for saved in savedDays {
            let savedDayStart = calendar.startOfDay(for: saved.date)
            if savedDayStart >= today {
                let isToday = calendar.isDateInToday(saved.date)
                let weekday = isToday ? "Today" : dateFormatter.string(from: saved.date)
                let dateLabel = dayFormatter.string(from: saved.date)
                let refreshed = MealPlanDay(
                    id: saved.id,
                    date: saved.date,
                    weekday: weekday,
                    dateLabel: dateLabel,
                    focus: saved.focus,
                    meals: saved.meals
                )
                validFutureDays.append(refreshed)
            }
        }

        if validFutureDays.isEmpty {
            return generateDays()
        }

        var finalDays = validFutureDays
        let existingDates = Set(finalDays.map { calendar.startOfDay(for: $0.date) })

        for offset in 0..<7 {
            guard let targetDate = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            let dayStart = calendar.startOfDay(for: targetDate)
            if !existingDates.contains(dayStart) {
                let isToday = calendar.isDateInToday(targetDate)
                let weekday = isToday ? "Today" : dateFormatter.string(from: targetDate)
                let dateLabel = dayFormatter.string(from: targetDate)
                let focus = focuses[offset % focuses.count]
                finalDays.append(MealPlanDay(
                    date: targetDate,
                    weekday: weekday,
                    dateLabel: dateLabel,
                    focus: focus,
                    meals: []
                ))
            }
        }

        finalDays.sort { $0.date < $1.date }
        return finalDays
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
                iconName: "sunrise.fill",
                imageURL: "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=800&q=80"
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
                iconName: "leaf.fill",
                imageURL: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80"
            ),
            PlannedMeal(
                title: "Tomato Lentil Soup",
                type: "Dinner",
                time: "7:30 PM",
                cookTime: "25 min",
                calories: 390,
                protein: 21,
                usesPantry: ["Lentils", "Tomatoes", "Carrots"],
                missingItems: ["Sourdough Bread"],
                iconName: "moon.stars.fill",
                imageURL: "https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80"
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
                iconName: "sunrise.fill",
                imageURL: "https://images.unsplash.com/photo-1511690656952-34342bb7c2f2?auto=format&fit=crop&w=800&q=80"
            ),
            PlannedMeal(
                title: "Veggie Fried Rice",
                type: "Lunch",
                time: "12:45 PM",
                cookTime: "18 min",
                calories: 520,
                protein: 18,
                usesPantry: ["Rice", "Tofu", "Peas"],
                missingItems: [],
                iconName: "leaf.fill",
                imageURL: "https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80"
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
