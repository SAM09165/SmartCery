import SwiftUI

struct MealPlannerview: View {
    @EnvironmentObject private var tabRouter: TabRouter
    @EnvironmentObject private var groceryMarketViewModel: GroceryMarketViewModel
    @StateObject private var viewModel = MealPlannerViewModel()
    @State private var showingAddMeal = false

    var body: some View {
        ZStack {
            AppTheme.softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    planHero
                    weekSelector
                    summaryRow
                    mealsSection
                    groceryGapSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTopBar(
                    title: "Meal Planner",
                    subtitle: viewModel.selectedDay.focus,
                    trailingIcon: "plus",
                    onTrailingTap: { showingAddMeal = true }
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
        .sheet(isPresented: $showingAddMeal) {
            AddMealSheet(dayLabel: "\(viewModel.selectedDay.weekday) \(viewModel.selectedDay.dateLabel)") { meal in
                viewModel.addMeal(
                    title: meal.title,
                    type: meal.type,
                    time: meal.time,
                    cookTime: meal.cookTime,
                    calories: meal.calories,
                    protein: meal.protein,
                    usesPantry: meal.usesPantry,
                    missingItems: meal.missingItems
                )
            }
        }
    }

    private var planHero: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.zestOrange)
                .frame(width: 42, height: 42)
                .background(AppTheme.cream, in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text("Chef Zest picked meals around your pantry.")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Tap a day to see prep time, pantry matches, nutrition, and what still needs to be bought.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppTheme.basilGreen.opacity(0.66))
                    .lineSpacing(2)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var weekSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.days) { day in
                    let isSelected = day.id == viewModel.selectedDayID

                    Button {
                        viewModel.selectedDayID = day.id
                    } label: {
                        VStack(spacing: 8) {
                            Text(day.weekday)
                                .font(.system(size: 12, weight: .semibold))

                            Text(day.dateLabel)
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundStyle(isSelected ? AppTheme.cream : AppTheme.basilGreen)
                        .frame(width: 58, height: 72)
                        .background(
                            isSelected ? AppTheme.basilGreen : AppTheme.elevatedSurface,
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(AppTheme.basilGreen.opacity(isSelected ? 0 : 0.12), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var summaryRow: some View {
        HStack(spacing: 10) {
            summaryTile(
                iconName: "flame.fill",
                value: "\(viewModel.dailyCalories)",
                label: "Calories"
            )
            summaryTile(
                iconName: "bolt.heart.fill",
                value: "\(viewModel.dailyProtein)g",
                label: "Protein"
            )
            summaryTile(
                iconName: "cabinet.fill",
                value: "\(viewModel.pantryItemCount)",
                label: "Pantry uses"
            )
        }
    }

    private func summaryTile(iconName: String, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.zestOrange)

            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.basilGreen)
                .lineLimit(1)

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppTheme.basilGreen.opacity(0.58))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Planned meals")

            if viewModel.selectedDay.meals.isEmpty {
                emptyPlanCard
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.selectedDay.meals) { meal in
                        mealCard(meal)
                    }
                }
            }
        }
    }

    private var emptyPlanCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(AppTheme.zestOrange)

            Text("No meals planned yet")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.basilGreen)

            Text("Use the add button to build this day from pantry items and market picks.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppTheme.basilGreen.opacity(0.64))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func mealCard(_ meal: PlannedMeal) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: meal.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppTheme.zestOrange)
                    .frame(width: 42, height: 42)
                    .background(AppTheme.cream, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.type)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.zestOrange)

                    Text(meal.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(meal.time) • \(meal.cookTime)")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AppTheme.basilGreen.opacity(0.62))
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                metricPill("\(meal.calories) cal", iconName: "flame")
                metricPill("\(meal.protein)g protein", iconName: "bolt.heart")
            }

            ingredientLine(title: "Uses", items: meal.usesPantry, color: AppTheme.basilGreen)

            if !meal.missingItems.isEmpty {
                ingredientLine(title: "Needs", items: meal.missingItems, color: AppTheme.zestOrange)
            }
        }
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func metricPill(_ text: String, iconName: String) -> some View {
        Label(text, systemImage: iconName)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(AppTheme.basilGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.cream, in: Capsule())
    }

    private func ingredientLine(title: String, items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(color)

            FlowLayout(spacing: 6) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(color)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(color.opacity(0.10), in: Capsule())
                }
            }
        }
    }

    private var groceryGapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Grocery gaps")

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                Image(systemName: viewModel.missingItems.isEmpty ? "checkmark.circle.fill" : "cart.badge.plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppTheme.zestOrange)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.cream, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.missingItems.isEmpty ? "You have everything for this day" : "\(viewModel.missingItems.count) item\(viewModel.missingItems.count == 1 ? "" : "s") to buy")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen)

                    Text(viewModel.missingItems.isEmpty ? "Nice pantry match." : viewModel.missingItems.joined(separator: ", "))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AppTheme.basilGreen.opacity(0.62))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

                if !viewModel.missingItems.isEmpty {
                    Button {
                        groceryMarketViewModel.focusMarket(on: viewModel.missingItems)
                        tabRouter.selectedTab = .market
                    } label: {
                        Label("Shop missing items", systemImage: "cart.badge.plus")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppTheme.cream)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(AppTheme.basilGreen, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(AppTheme.basilGreen)
    }
}

private struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: spacing) {
                content
            }

            VStack(alignment: .leading, spacing: spacing) {
                content
            }
        }
    }
}

private struct AddMealDraft {
    var title = ""
    var type = "Breakfast"
    var time = "8:00 AM"
    var cookTime = "20 min"
    var calories = "450"
    var protein = "20"
    var usesPantry = ""
    var missingItems = ""

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var plannedMealInput: PlannedMealInput {
        PlannedMealInput(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            time: time.trimmingCharacters(in: .whitespacesAndNewlines),
            cookTime: cookTime.trimmingCharacters(in: .whitespacesAndNewlines),
            calories: Int(calories) ?? 0,
            protein: Int(protein) ?? 0,
            usesPantry: splitList(usesPantry),
            missingItems: splitList(missingItems)
        )
    }

    private func splitList(_ value: String) -> [String] {
        value
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

private struct PlannedMealInput {
    let title: String
    let type: String
    let time: String
    let cookTime: String
    let calories: Int
    let protein: Int
    let usesPantry: [String]
    let missingItems: [String]
}

private struct AddMealSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft = AddMealDraft()

    let dayLabel: String
    let onAdd: (PlannedMealInput) -> Void
    private let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.softCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Add to \(dayLabel)")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(AppTheme.basilGreen)

                            Text("Build one meal with enough detail for pantry matching and grocery gaps.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(AppTheme.basilGreen.opacity(0.64))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Picker("Meal type", selection: $draft.type) {
                            ForEach(mealTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)

                        fieldGroup {
                            plannerTextField("Meal name", text: $draft.title)
                            plannerTextField("Time", text: $draft.time)
                            plannerTextField("Cook time", text: $draft.cookTime)
                        }

                        fieldGroup {
                            plannerTextField("Calories", text: $draft.calories)
                                .keyboardType(.numberPad)
                            plannerTextField("Protein grams", text: $draft.protein)
                                .keyboardType(.numberPad)
                        }

                        fieldGroup {
                            plannerTextField("Uses from pantry", text: $draft.usesPantry, prompt: "Paneer, Spinach, Rice")
                            plannerTextField("Needs from market", text: $draft.missingItems, prompt: "Lemon, Parsley")
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(draft.plannedMealInput)
                        dismiss()
                    }
                    .disabled(!draft.isValid)
                }
            }
        }
    }

    private func fieldGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 12) {
            content()
        }
        .padding(14)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func plannerTextField(_ title: String, text: Binding<String>, prompt: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.basilGreen.opacity(0.72))

            TextField(prompt ?? title, text: text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.basilGreen)
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 11)
                .background(AppTheme.cream, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

#Preview {
    MealPlannerview()
        .environmentObject(TabRouter())
        .environmentObject(GroceryMarketViewModel())
}
