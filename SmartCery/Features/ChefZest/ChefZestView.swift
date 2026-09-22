//
//  ChefZestView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct ChefZestView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var tabRouter: TabRouter
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChefZestViewModel()
    @StateObject private var mealPlannerViewModel = MealPlannerViewModel()

    @State private var addedToPlannerSuccess = false
    @State private var isScrolled = false

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange
    private let cream = AppTheme.cream
    private let softCream = AppTheme.softCream
    private let elevatedSurface = AppTheme.elevatedSurface

    private var userDiet: DietaryPreference {
        store.profile?.dietPreference ?? .pureVeg
    }

    var body: some View {
        ZStack {
            softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Geometry Reader for Scroll Offset Tracking
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("chefZestScroll")).minY
                        )
                    }
                    .frame(height: 0)

                    // 1. HERO AI CARD
                    heroCard

                    // 2. STRICT DIET PREFERENCE CARD
                    dietBadgeCard

                    // 3. DIET GOAL SELECTOR
                    dietGoalSelector

                    // 4. AI CHAT CONSULTATION SECTION
                    aiChatAssistantSection

                    // 5. PANTRY-MATCHED RECIPE RECOMMENDATIONS
                    recommendationsSection

                    // 6. SMART GROCERY REPLENISHMENTS
                    smartGroceryAddsSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .coordinateSpace(name: "chefZestScroll")
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
                    title: "Chef Zest AI",
                    subtitle: "Personalized AI Dietitian",
                    showBack: false,
                    isScrolled: isScrolled
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear(perform: refresh)
        .onChange(of: store.pantry) { _, _ in refresh() }
        .onChange(of: store.groceryList) { _, _ in refresh() }
        .onChange(of: store.profile) { _, _ in refresh() }
        .onChange(of: viewModel.selectedDietGoal) { _, _ in refresh() }
    }

    // MARK: - 1. HERO AI CARD
    private var heroCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(cream)
                    .frame(width: 48, height: 48)

                Image(systemName: "sparkles")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(zestOrange)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("AI NUTRITIONIST")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(basilGreen.opacity(0.7))
                        .tracking(1.0)

                    Text("LIVE")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(cream)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green, in: Capsule())
                }

                Text(viewModel.headline)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(basilGreen)

                Text(viewModel.subheadline)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(basilGreen.opacity(0.75))
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(elevatedSurface)

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [basilGreen.opacity(0.06), zestOrange.opacity(0.06)],
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

    // MARK: - 2. DIET BADGE CARD
    private var dietBadgeCard: some View {
        HStack(spacing: 12) {
            Image(systemName: userDiet.badgeIcon)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(userDiet.isStrictVeg ? Color.green : zestOrange)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("Active Diet Filter:")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(basilGreen.opacity(0.65))

                    Text(userDiet.rawValue)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(basilGreen)
                }

                Text(userDiet.description)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(basilGreen.opacity(0.7))
            }

            Spacer()
        }
        .padding(14)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(userDiet.isStrictVeg ? Color.green.opacity(0.4) : zestOrange.opacity(0.4), lineWidth: 1.2)
        )
    }

    // MARK: - 3. DIET GOAL SELECTOR
    private var dietGoalSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dietary Goal Focus")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(basilGreen)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DietGoal.allCases) { goal in
                        let isSelected = goal == viewModel.selectedDietGoal

                        Button {
                            HapticManager.impact(.light)
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                                viewModel.selectedDietGoal = goal
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: goal.iconName)
                                    .font(.system(size: 10, weight: .bold))
                                Text(goal.rawValue)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(isSelected ? cream : basilGreen)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isSelected ? zestOrange : elevatedSurface, in: Capsule())
                            .shadow(color: isSelected ? zestOrange.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - 4. AI CHAT CONSULTATION SECTION
    private var aiChatAssistantSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("AI Personal Consultation", systemImage: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen)

                Spacer()

                if viewModel.isThinking {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                // Messages log
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.chatMessages) { msg in
                        HStack {
                            if msg.sender == .user { Spacer() }

                            VStack(alignment: msg.sender == .user ? .trailing : .leading, spacing: 4) {
                                Text(msg.sender == .user ? "You" : "Chef Zest AI")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(msg.sender == .user ? zestOrange : basilGreen)

                                Text(msg.text)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(msg.sender == .user ? cream : basilGreen)
                                    .lineSpacing(2)
                                    .padding(12)
                                    .background(
                                        msg.sender == .user ? basilGreen : cream,
                                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    )
                                    .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                            }

                            if msg.sender == .chefZest { Spacer() }
                        }
                    }
                }

                // Quick Prompt Chips (SF Symbols, 0 Emojis)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        quickPromptButton(icon: "fork.knife", text: "High-protein lunch")
                        quickPromptButton(icon: "arrow.triangle.2.circlepath", text: "Zero-waste dinner")
                        quickPromptButton(icon: "clock.fill", text: "Under 15-min snack")
                        quickPromptButton(icon: "chart.bar.fill", text: "Calculate macros")
                    }
                }

                // Chat Input Box
                HStack(spacing: 10) {
                    TextField("Ask Chef Zest for recipe or diet advice...", text: $viewModel.userPromptText)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(basilGreen)
                        .submitLabel(.send)
                        .onSubmit {
                            HapticManager.impact(.light)
                            viewModel.sendUserMessage(pantry: store.pantry, profile: store.profile)
                        }

                    Button {
                        HapticManager.impact(.medium)
                        viewModel.sendUserMessage(pantry: store.pantry, profile: store.profile)
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(cream)
                            .frame(width: 36, height: 36)
                            .background(zestOrange, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.userPromptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(cream, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(14)
            .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private func quickPromptButton(icon: String, text: String) -> some View {
        Button {
            HapticManager.impact(.light)
            viewModel.sendUserMessage(text, pantry: store.pantry, profile: store.profile)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                Text(text)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
            }
            .foregroundStyle(basilGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(cream, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - 5. RECOMMENDATIONS SECTION
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pantry-Matched Diet Recipes (\(userDiet.rawValue))")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(basilGreen)

            if viewModel.recommendations.isEmpty {
                compactStatusCard(
                    iconName: "cabinet.fill",
                    title: "No recipes matched",
                    message: "Add a few \(userDiet.rawValue) ingredients to your pantry and Chef Zest will match meals automatically."
                )
            } else {
                VStack(spacing: 14) {
                    ForEach(viewModel.recommendations) { recommendation in
                        liquidRecipeCard(recommendation)
                    }
                }
            }
        }
    }

    private func liquidRecipeCard(_ recipe: PantryRecipeRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Recipe Real Food Photography Showcase
            ZStack(alignment: .topTrailing) {
                RecipeImageView(
                    title: recipe.title,
                    imageURL: recipe.imageURL,
                    iconName: recipe.iconName,
                    contentMode: .fill,
                    cornerRadius: 16
                )
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .clipped()

                // Top badges
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9, weight: .bold))
                        Text("\(recipe.matchScore)% Match")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(zestOrange, in: Capsule())
                    .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 1)

                    Spacer()

                    Text(recipe.dietCategory.rawValue)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(basilGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.92), in: Capsule())
                        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
                }
                .padding(10)
            }
            .frame(height: 140)
            .background(Color.black.opacity(0.03), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen)

                Text(recipe.summary)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(basilGreen.opacity(0.75))
                    .lineLimit(2)
            }

            // Macro Metrics Pills
            HStack(spacing: 8) {
                macroPill("\(recipe.calories) kcal", iconName: "flame.fill", color: zestOrange)
                macroPill("\(recipe.proteinGrams)g Protein", iconName: "bolt.heart.fill", color: basilGreen)
                macroPill(recipe.cookTime, iconName: "clock.fill", color: basilGreen.opacity(0.7))
            }

            chipLine(title: "Uses from Pantry:", items: recipe.usesPantry, color: Color.green)

            if !recipe.missingItems.isEmpty {
                chipLine(title: "Needs from Market:", items: recipe.missingItems, color: zestOrange)
            }

            // Action Buttons
            HStack(spacing: 10) {
                Button {
                    HapticManager.impact(.medium)
                    mealPlannerViewModel.addMeal(
                        title: recipe.title,
                        type: "Lunch",
                        time: "1:00 PM",
                        cookTime: recipe.cookTime,
                        calories: recipe.calories,
                        protein: recipe.proteinGrams,
                        usesPantry: recipe.usesPantry,
                        missingItems: recipe.missingItems,
                        imageURL: recipe.imageURL
                    )
                    withAnimation {
                        addedToPlannerSuccess = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation {
                            addedToPlannerSuccess = false
                        }
                    }
                } label: {
                    Label(addedToPlannerSuccess ? "Synced to Planner!" : "Sync to Meal Planner", systemImage: addedToPlannerSuccess ? "checkmark.circle.fill" : "calendar.badge.plus")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(cream)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(addedToPlannerSuccess ? Color.green : basilGreen, in: Capsule())
                }
                .buttonStyle(.plain)

                if !recipe.missingItems.isEmpty {
                    Button {
                        HapticManager.impact(.medium)
                        tabRouter.selectedTab = .market
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "cart.badge.plus")
                                .font(.system(size: 11, weight: .bold))
                            Text("Buy (\(recipe.missingItems.count))")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(zestOrange)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(zestOrange.opacity(0.12), in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.8), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func macroPill(_ text: String, iconName: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(basilGreen)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(cream, in: Capsule())
    }

    private func chipLine(title: String, items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(basilGreen.opacity(0.7))

            HStack(spacing: 6) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(color.opacity(0.12), in: Capsule())
                }
            }
        }
    }

    // MARK: - 6. SMART GROCERY ADDS
    private var smartGroceryAddsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Auto-Restock for \(userDiet.rawValue) Recipes")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(basilGreen)

            ForEach(viewModel.grocerySuggestions, id: \.self) { grocery in
                HStack {
                    Image(systemName: "bag.badge.plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(zestOrange)

                    Text(grocery)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(basilGreen)

                    Spacer()

                    Button {
                        HapticManager.impact(.light)
                        store.addGroceryItem(name: grocery)
                    } label: {
                        Text("Add to List")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(basilGreen)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(cream, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private func compactStatusCard(iconName: String, title: String, message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(zestOrange)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(basilGreen)
                Text(message)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(basilGreen.opacity(0.75))
            }
            Spacer()
        }
        .padding(14)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func refresh() {
        viewModel.refresh(
            pantry: store.pantry,
            groceryList: store.groceryList,
            profile: store.profile
        )
    }
}
