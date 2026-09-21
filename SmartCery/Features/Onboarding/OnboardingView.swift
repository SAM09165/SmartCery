//
//  OnboardingView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: AppStore
    @StateObject private var viewModel = OnboardingViewModel()

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange
    private let cream = AppTheme.cream
    private let softCream = AppTheme.softCream
    private let elevatedSurface = AppTheme.elevatedSurface

    var body: some View {
        ZStack {
            softCream.ignoresSafeArea()

            VStack(spacing: 20) {
                topBar

                if viewModel.isIntakePage {
                    ScrollView(showsIndicators: false) {
                        intakeFormContent
                            .padding(.bottom, 20)
                    }
                } else {
                    TabView(selection: $viewModel.currentPageIndex) {
                        ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                            onboardingPage(page)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    pageDots
                }

                actionBar
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 22)
        }
    }

    private var topBar: some View {
        HStack {
            Label("SmartCery", systemImage: "sparkles")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(basilGreen)

            Spacer()

            if !viewModel.isIntakePage {
                Button("Skip to Details") {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        viewModel.skipToLastPage()
                    }
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(zestOrange)
            }
        }
    }

    private func onboardingPage(_ page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer(minLength: 8)

            ZStack {
                Circle()
                    .fill(cream)
                    .frame(width: 180, height: 180)

                Image(systemName: page.iconName)
                    .font(.system(size: 80, weight: .semibold))
                    .foregroundStyle(zestOrange)
                    .symbolRenderingMode(.hierarchical)
            }
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "sparkles")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(basilGreen)
                    .padding(16)
                    .background(softCream, in: Circle())
            }

            VStack(spacing: 10) {
                Text(page.eyebrow.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(zestOrange)

                Text(page.title)
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(basilGreen)
                    .fixedSize(horizontal: false, vertical: true)

                Text(page.message)
                    .font(.system(size: 15, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(basilGreen.opacity(0.74))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            chefBubble(page.chefLine)

            Spacer(minLength: 8)
        }
    }

    private func chefBubble(_ line: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(zestOrange)

            Text(line)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(basilGreen)
                .lineSpacing(2)

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0...viewModel.pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == viewModel.currentPageIndex ? zestOrange : basilGreen.opacity(0.18))
                    .frame(width: index == viewModel.currentPageIndex ? 24 : 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.currentPageIndex)
    }

    // Intake Form Content
    private var intakeFormContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Personal Health Profile")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(basilGreen)

                Text("SmartCery calculates your exact BMR & TDEE macro targets and strictly enforces your dietary boundaries.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(basilGreen.opacity(0.68))
                    .lineSpacing(2)
            }

            // Target Macro Calculation Live Preview Card
            calculatedMacrosBanner

            // Personal Metrics (Age, Gender, Height, Weight)
            VStack(alignment: .leading, spacing: 14) {
                Text("Body Metrics")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(basilGreen)

                HStack(spacing: 12) {
                    metricInputCard(title: "Age", value: "\(viewModel.age) yrs", icon: "number") {
                        if viewModel.age > 12 { viewModel.age -= 1 }
                    } onPlus: {
                        if viewModel.age < 90 { viewModel.age += 1 }
                    }

                    metricInputCard(title: "Height", value: "\(Int(viewModel.heightCm)) cm", icon: "ruler") {
                        if viewModel.heightCm > 120 { viewModel.heightCm -= 1 }
                    } onPlus: {
                        if viewModel.heightCm < 220 { viewModel.heightCm += 1 }
                    }

                    metricInputCard(title: "Weight", value: "\(Int(viewModel.weightKg)) kg", icon: "scalemass") {
                        if viewModel.weightKg > 35 { viewModel.weightKg -= 1 }
                    } onPlus: {
                        if viewModel.weightKg < 200 { viewModel.weightKg += 1 }
                    }
                }

                // Gender selector
                HStack(spacing: 10) {
                    Text("Gender:")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(basilGreen)

                    ForEach(["Male", "Female", "Other"], id: \.self) { item in
                        let isSelected = viewModel.gender == item
                        Button {
                            viewModel.gender = item
                        } label: {
                            Text(item)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(isSelected ? cream : basilGreen)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isSelected ? basilGreen : cream, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

            // Strict Dietary Preference Section (Critical for India)
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.shield.fill")
                        .foregroundStyle(zestOrange)

                    Text("Strict Dietary Preference (Enforced App-wide)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(basilGreen)
                }

                VStack(spacing: 10) {
                    ForEach(DietaryPreference.allCases) { pref in
                        let isSelected = pref == viewModel.dietPreference

                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                viewModel.dietPreference = pref
                            }
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(isSelected ? zestOrange : basilGreen.opacity(0.3))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(pref.rawValue)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(basilGreen)

                                    Text(pref.description)
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(basilGreen.opacity(0.65))
                                        .lineSpacing(2)
                                }
                                Spacer()
                            }
                            .padding(14)
                            .background(isSelected ? zestOrange.opacity(0.08) : cream, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(isSelected ? zestOrange : Color.clear, lineWidth: 1.5)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

            // Workout Frequency
            VStack(alignment: .leading, spacing: 12) {
                Text("Workout & Activity Level")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(basilGreen)

                VStack(spacing: 8) {
                    ForEach(WorkoutFrequency.allCases) { freq in
                        let isSelected = freq == viewModel.workoutFrequency

                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                viewModel.workoutFrequency = freq
                            }
                        } label: {
                            HStack {
                                Text(freq.rawValue)
                                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                                    .foregroundStyle(isSelected ? cream : basilGreen)

                                Spacer()

                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(cream)
                                }
                            }
                            .padding(12)
                            .background(isSelected ? basilGreen : cream, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

            // Primary Fitness Goal
            VStack(alignment: .leading, spacing: 12) {
                Text("Primary Health Goal")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(basilGreen)

                VStack(spacing: 8) {
                    ForEach(FitnessGoal.allCases) { goal in
                        let isSelected = goal == viewModel.fitnessGoal

                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                viewModel.fitnessGoal = goal
                            }
                        } label: {
                            HStack {
                                Text(goal.rawValue)
                                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                                    .foregroundStyle(isSelected ? cream : basilGreen)

                                Spacer()

                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(cream)
                                }
                            }
                            .padding(12)
                            .background(isSelected ? zestOrange : cream, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var calculatedMacrosBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bolt.heart.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(zestOrange)

                Text("Calculated Macro Plan")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(zestOrange)

                Spacer()

                Text("BMR: \(Int(viewModel.calculatedBMR)) kcal")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(basilGreen.opacity(0.6))
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.calculatedTargetCalories) kcal")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(basilGreen)

                    Text("Daily Calorie Target")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(basilGreen.opacity(0.65))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(viewModel.calculatedTargetProtein)g")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(zestOrange)

                    Text("Daily Protein Goal")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(basilGreen.opacity(0.65))
                }
            }
        }
        .padding(16)
        .background(cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(zestOrange.opacity(0.3), lineWidth: 1.2)
        }
    }

    private func metricInputCard(title: String, value: String, icon: String, onMinus: @escaping () -> Void, onPlus: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(basilGreen.opacity(0.6))

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(basilGreen)

            HStack(spacing: 8) {
                Button(action: onMinus) {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(basilGreen)
                        .frame(width: 26, height: 26)
                        .background(cream, in: Circle())
                }
                .buttonStyle(.plain)

                Button(action: onPlus) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(cream)
                        .frame(width: 26, height: 26)
                        .background(zestOrange, in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(cream, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var actionBar: some View {
        Button {
            if viewModel.isIntakePage {
                let userProfile = viewModel.buildUserProfile()
                store.setProfile(userProfile)
                store.completeOnboarding()
                router.completeOnboarding()
            } else {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    viewModel.goNext()
                }
            }
        } label: {
            HStack {
                Text(viewModel.primaryButtonTitle)
                    .font(.system(size: 17, weight: .bold))

                Image(systemName: viewModel.isIntakePage ? "checkmark.circle.fill" : "arrow.right")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(cream)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(basilGreen, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppRouter())
        .environmentObject(AppStore())
}
