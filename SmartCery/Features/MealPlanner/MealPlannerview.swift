//
//  MealPlannerview.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct MealPlannerview: View {
    @EnvironmentObject private var tabRouter: TabRouter
    @EnvironmentObject private var groceryMarketViewModel: GroceryMarketViewModel
    @EnvironmentObject private var store: AppStore
    @StateObject private var viewModel = MealPlannerViewModel()

    @State private var showingAddMeal = false
    @State private var showingChefZest = false
    @State private var isScrolled = false

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange
    private let cream = AppTheme.cream
    private let softCream = AppTheme.softCream
    private let elevatedSurface = AppTheme.elevatedSurface

    var body: some View {
        ZStack {
            softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Geometry Reader for Scroll Offset Tracking
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("mealPlannerScroll")).minY
                        )
                    }
                    .frame(height: 0)

                    // 1. MACRO RINGS & NUTRITION DASHBOARD HERO
                    macroRingsHeroCard

                    // 2. DAY SELECTOR CAROUSEL
                    weekSelectorCarousel

                    // 3. CHEF ZEST AI RECIPE & DIET ASSISTANT STRIP
                    chefZestAiStrip

                    // 4. PLANNED MEALS SECTION
                    plannedMealsSection

                    // 5. GROCERY GAPS & SMART SHOPPING DRAWER
                    groceryGapSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .coordinateSpace(name: "mealPlannerScroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { minY in
                let scrolled = minY < -15
                if scrolled != isScrolled {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                        isScrolled = scrolled
                    }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                AppTopBar(
                    title: "AI Meal Planner",
                    subtitle: "\(viewModel.selectedDay.weekday) • \(viewModel.selectedDay.focus)",
                    trailingIcon: "plus",
                    badgeCount: viewModel.selectedDay.meals.count,
                    onTrailingTap: {
                        HapticManager.impact(.medium)
                        showingAddMeal = true
                    },
                    isScrolled: isScrolled
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
        .sheet(isPresented: $showingChefZest) {
            ChefZestView()
                .environmentObject(store)
                .environmentObject(tabRouter)
        }
    }

    // MARK: - 1. MACRO RINGS HERO CARD
    private var macroRingsHeroCard: some View {
        HStack(spacing: 20) {
            // Concentric Progress Rings (Calories & Protein)
            ZStack {
                // Background Track 1 (Calories)
                Circle()
                    .stroke(zestOrange.opacity(0.18), lineWidth: 9)
                    .frame(width: 88, height: 88)

                // Calories Progress Ring
                Circle()
                    .trim(from: 0, to: viewModel.calorieProgress)
                    .stroke(
                        LinearGradient(colors: [zestOrange, Color.yellow], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 9, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 88, height: 88)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.calorieProgress)

                // Background Track 2 (Protein)
                Circle()
                    .stroke(basilGreen.opacity(0.18), lineWidth: 7)
                    .frame(width: 66, height: 66)

                // Protein Progress Ring
                Circle()
                    .trim(from: 0, to: viewModel.proteinProgress)
                    .stroke(
                        LinearGradient(colors: [basilGreen, Color.green], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 66, height: 66)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.proteinProgress)

                // Center Flame Icon
                Image(systemName: "flame.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(zestOrange)
            }

            // Macro Metrics Breakdown
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("DAILY MACRO GOALS")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(basilGreen.opacity(0.7))
                        .tracking(1.0)

                    Spacer()

                    Text("\(Int(viewModel.calorieProgress * 100))% Goal")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(zestOrange)
                }

                HStack(spacing: 12) {
                    macroMetricColumn(
                        label: "CALORIES",
                        current: "\(viewModel.dailyCalories)",
                        target: "\(viewModel.targetCalories) kcal",
                        color: zestOrange,
                        icon: "flame.fill"
                    )

                    macroMetricColumn(
                        label: "PROTEIN",
                        current: "\(viewModel.dailyProtein)g",
                        target: "\(viewModel.targetProtein)g",
                        color: basilGreen,
                        icon: "bolt.heart.fill"
                    )
                }

                // Sub-Macro Chips
                HStack(spacing: 8) {
                    macroChip(label: "Pantry: \(viewModel.pantryItemCount) Items", color: .green)
                    macroChip(label: "Missing: \(viewModel.missingItems.count) Items", color: zestOrange)
                }
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(elevatedSurface)

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [basilGreen.opacity(0.05), zestOrange.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.8), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    private func macroMetricColumn(label: String, current: String, target: String, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)

                Text(label)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(basilGreen.opacity(0.6))
            }

            Text(current)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(basilGreen)

            Text("of \(target)")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(basilGreen.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func macroChip(label: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 5, height: 5)

            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(basilGreen)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12), in: Capsule())
    }

    // MARK: - 2. WEEK SELECTOR CAROUSEL
    private var weekSelectorCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.days) { day in
                    let isSelected = day.id == viewModel.selectedDayID
                    let isToday = day.weekday == "Today"

                    Button {
                        HapticManager.impact(.light)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                            viewModel.selectedDayID = day.id
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(day.weekday.uppercased())
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(isSelected ? cream : basilGreen.opacity(0.7))

                            Text(day.dateLabel)
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundStyle(isSelected ? cream : basilGreen)

                            if isToday {
                                Circle()
                                    .fill(isSelected ? cream : zestOrange)
                                    .frame(width: 5, height: 5)
                            }
                        }
                        .frame(width: 62, height: 72)
                        .background(
                            isSelected ? basilGreen : elevatedSurface,
                            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(
                                    isToday ? zestOrange : Color.white.opacity(isSelected ? 0 : 0.8),
                                    lineWidth: isToday ? 2 : 1
                                )
                        )
                        .shadow(color: isSelected ? basilGreen.opacity(0.3) : Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    // MARK: - 3. CHEF ZEST AI STRIP
    private var chefZestAiStrip: some View {
        Button {
            HapticManager.impact(.medium)
            showingChefZest = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(cream)
                        .frame(width: 38, height: 38)

                    Image(systemName: "sparkles")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(zestOrange)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Chef Zest AI Meal Optimizer")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(basilGreen)

                    Text("Pantry-matched meals for \(viewModel.selectedDay.weekday) (\(viewModel.selectedDay.focus))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(basilGreen.opacity(0.75))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(zestOrange)
            }
            .padding(12)
            .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 4. PLANNED MEALS SECTION
    private var plannedMealsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Planned Meals")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen)

                Spacer()

                Button {
                    HapticManager.impact(.medium)
                    showingAddMeal = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                        Text("Add Meal")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(cream)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(basilGreen, in: Capsule())
                }
                .buttonStyle(.plain)
            }

            if viewModel.selectedDay.meals.isEmpty {
                emptyPlanCard
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.selectedDay.meals) { meal in
                        liquidMealCard(meal)
                    }
                }
            }
        }
    }

    private var emptyPlanCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(cream)
                    .frame(width: 60, height: 60)

                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(zestOrange)
            }

            VStack(spacing: 4) {
                Text("No Meals Planned For This Day")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen)

                Text("Tap '+ Add Meal' to build your breakfast, lunch, or dinner from pantry ingredients!")
                    .font(.system(size: 12, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(basilGreen.opacity(0.68))
                    .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func liquidMealCard(_ meal: PlannedMeal) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack(alignment: .top, spacing: 12) {
                RecipeImageView(
                    title: meal.title,
                    imageURL: meal.imageURL,
                    iconName: meal.iconName,
                    contentMode: .fill,
                    cornerRadius: 14
                )
                .frame(width: 54, height: 54)
                .clipped()
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(meal.type.uppercased())
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(zestOrange)

                        Text("•")
                            .font(.system(size: 10))
                            .foregroundStyle(basilGreen.opacity(0.3))

                        Text("\(meal.time) • \(meal.cookTime)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(basilGreen.opacity(0.65))
                    }

                    Text(meal.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(basilGreen)

                    HStack(spacing: 8) {
                        metricChip("\(meal.calories) kcal", icon: "flame.fill", color: zestOrange)
                        metricChip("\(meal.protein)g Protein", icon: "bolt.heart.fill", color: basilGreen)
                    }
                    .padding(.top, 2)
                }

                Spacer(minLength: 0)

                Button {
                    HapticManager.impact(.medium)
                    withAnimation {
                        viewModel.deleteMeal(id: meal.id)
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.red.opacity(0.7))
                        .padding(8)
                        .background(Color.red.opacity(0.08), in: Circle())
                }
                .buttonStyle(.plain)
            }

            // Ingredient Line Badges
            if !meal.usesPantry.isEmpty {
                ingredientBadgeLine(title: "Uses Pantry", items: meal.usesPantry, color: .green, icon: "checkmark.circle.fill")
            }

            if !meal.missingItems.isEmpty {
                ingredientBadgeLine(title: "Needs Market", items: meal.missingItems, color: zestOrange, icon: "cart.badge.plus")
            }
        }
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(elevatedSurface)

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.4))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.9), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }

    private func metricChip(_ text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)

            Text(text)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(basilGreen)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(color.opacity(0.12), in: Capsule())
    }

    private func ingredientBadgeLine(title: String, items: [String], color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)

                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(color)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(color.opacity(0.12), in: Capsule())
                    }
                }
            }
        }
    }

    // MARK: - 5. GROCERY GAPS SECTION
    private var groceryGapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Grocery Gaps")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen)

                Spacer()

                if !viewModel.missingItems.isEmpty {
                    Text("\(viewModel.missingItems.count) to buy")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(cream)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(zestOrange, in: Capsule())
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(cream)
                            .frame(width: 40, height: 40)

                        Image(systemName: viewModel.missingItems.isEmpty ? "checkmark.circle.fill" : "cart.badge.plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(viewModel.missingItems.isEmpty ? Color.green : zestOrange)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel.missingItems.isEmpty ? "All Ingredients Stocked!" : "Missing Ingredients for \(viewModel.selectedDay.weekday)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(basilGreen)

                        Text(viewModel.missingItems.isEmpty ? "Your kitchen has everything required for today's plan." : viewModel.missingItems.joined(separator: ", "))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(basilGreen.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                if !viewModel.missingItems.isEmpty {
                    Button {
                        HapticManager.impact(.medium)
                        groceryMarketViewModel.focusMarket(on: viewModel.missingItems)
                        tabRouter.selectedTab = .market
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("Shop Missing Items in 10 Mins")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(cream)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(basilGreen, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: basilGreen.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(14)
            .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

// MARK: - ADD MEAL DRAFT STRUCTS
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
                                .font(.system(size: 24, weight: .bold, design: .rounded))
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
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.basilGreen.opacity(0.72))

            TextField(prompt ?? title, text: text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
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
        .environmentObject(AppStore())
}
