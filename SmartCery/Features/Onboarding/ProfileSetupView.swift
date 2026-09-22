import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var sessionManager: SessionManager

    let needsPantrySeed: Bool

    @State private var currentStep: Int = 1
    private let totalSteps: Int = 6

    @State private var displayName: String = ""
    @State private var gender: String = "Male"
    @State private var age: Int = 26
    @State private var heightCm: Double = 175.0
    @State private var weightKg: Double = 70.0
    @State private var dietPreference: DietaryPreference = .pureVeg
    @State private var workoutFrequency: WorkoutFrequency = .moderate
    @State private var fitnessGoal: FitnessGoal = .fatLoss
    @State private var isSaving: Bool = false

    private var currentProfile: UserProfile {
        UserProfile(
            displayName: displayName.isEmpty ? (store.profile?.displayName ?? "Kitchen Hero") : displayName,
            email: store.profile?.email ?? "",
            age: age,
            gender: gender,
            heightCm: heightCm,
            weightKg: weightKg,
            dietPreference: dietPreference,
            workoutFrequency: workoutFrequency,
            fitnessGoal: fitnessGoal,
            profileCompleted: true
        )
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Navigation & Step Indicator
                topStepBar

                // Step Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        switch currentStep {
                        case 1:
                            genderStepView
                        case 2:
                            ageStepView
                        case 3:
                            heightStepView
                        case 4:
                            weightStepView
                        case 5:
                            dietStepView
                        case 6:
                            goalsStepView
                        default:
                            genderStepView
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.md)
                    .padding(.bottom, 120)
                }

                Spacer(minLength: 0)
            }

            // Bottom Floating Action Button
            VStack {
                Spacer()
                bottomActionBar
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if let existing = store.profile {
                displayName = existing.displayName
                age = existing.age
                gender = existing.gender
                heightCm = existing.heightCm
                weightKg = existing.weightKg
                dietPreference = existing.dietPreference
                workoutFrequency = existing.workoutFrequency
                fitnessGoal = existing.fitnessGoal
            }
        }
    }

    // MARK: - Top Step Navigation Bar
    private var topStepBar: some View {
        VStack(spacing: 12) {
            HStack {
                if currentStep > 1 {
                    Button {
                        HapticManager.impact(.light)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            currentStep -= 1
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                            Text("Back")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(AppTheme.textPrimary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear
                        .frame(width: 50, height: 20)
                }

                Spacer()

                Text("Step \(currentStep) of \(totalSteps)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)

                Spacer()

                Button {
                    // Skip button to advance quickly
                    advanceStep()
                } label: {
                    Text(currentStep == totalSteps ? "" : "Skip")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
                .frame(width: 50, alignment: .trailing)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, 14)

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.borderSubtle)
                        .frame(height: 5)

                    Capsule()
                        .fill(AppTheme.primary)
                        .frame(width: geo.size.width * CGFloat(currentStep) / CGFloat(totalSteps), height: 5)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                }
            }
            .frame(height: 5)
            .padding(.horizontal, AppSpacing.lg)
        }
        .background(AppTheme.background)
    }

    // MARK: - Step 1: Gender
    private var genderStepView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeader(
                title: "What is your gender?",
                subtitle: "Chef Zest uses your biological sex to compute accurate basal metabolic rates and daily nutrient targets."
            )

            VStack(spacing: AppSpacing.md) {
                genderCard(title: "Male", icon: "figure.stand")
                genderCard(title: "Female", icon: "figure.stand.dress")
                genderCard(title: "Prefer not to say", icon: "person.fill")
            }
        }
    }

    private func genderCard(title: String, icon: String) -> some View {
        let isSelected = gender.caseInsensitiveCompare(title) == .orderedSame
        return Button {
            HapticManager.impact(.light)
            gender = title
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppTheme.primary.opacity(0.12) : AppTheme.surface)
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(isSelected ? AppTheme.primary : AppTheme.textSecondary)
                }

                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isSelected ? AppTheme.primary : AppTheme.borderSubtle)
            }
            .padding(AppSpacing.md)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .stroke(isSelected ? AppTheme.primary : AppTheme.borderSubtle, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 2: Age
    private var ageStepView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeader(
                title: "How old are you?",
                subtitle: "Metabolism and micro-nutrient requirements adjust systematically across different life stages."
            )

            VStack(spacing: 24) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(age)")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(AppTheme.primary)

                    Text("years old")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.xlarge, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xlarge, style: .continuous)
                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                )

                // Quick Increment Buttons
                HStack(spacing: 16) {
                    metricAdjustButton(icon: "minus", label: "-1") {
                        if age > 14 { age -= 1 }
                    }

                    metricAdjustButton(icon: "minus", label: "-5") {
                        if age > 18 { age -= 5 }
                    }

                    metricAdjustButton(icon: "plus", label: "+5") {
                        if age < 95 { age += 5 }
                    }

                    metricAdjustButton(icon: "plus", label: "+1") {
                        if age < 99 { age += 1 }
                    }
                }

                // Slider
                VStack(spacing: 8) {
                    Slider(value: Binding(
                        get: { Double(age) },
                        set: { age = Int($0) }
                    ), in: 14...99, step: 1)
                    .tint(AppTheme.primary)

                    HStack {
                        Text("14 yrs")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                        Text("99 yrs")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Step 3: Height
    private var heightStepView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeader(
                title: "What is your height?",
                subtitle: "Height determines your lean mass baseline and resting caloric burn."
            )

            let feet = Int(heightCm / 30.48)
            let inches = Int((heightCm.truncatingRemainder(dividingBy: 30.48)) / 2.54)

            VStack(spacing: 24) {
                VStack(spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(Int(heightCm))")
                            .font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.primary)

                        Text("cm")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Text("(\(feet) ft \(inches) in)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.warmAccent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.xlarge, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xlarge, style: .continuous)
                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                )

                // Quick Increment Buttons
                HStack(spacing: 16) {
                    metricAdjustButton(icon: "minus", label: "-5") {
                        if heightCm > 125 { heightCm -= 5 }
                    }

                    metricAdjustButton(icon: "minus", label: "-1") {
                        if heightCm > 121 { heightCm -= 1 }
                    }

                    metricAdjustButton(icon: "plus", label: "+1") {
                        if heightCm < 229 { heightCm += 1 }
                    }

                    metricAdjustButton(icon: "plus", label: "+5") {
                        if heightCm < 225 { heightCm += 5 }
                    }
                }

                // Slider
                VStack(spacing: 8) {
                    Slider(value: $heightCm, in: 120...230, step: 1)
                        .tint(AppTheme.primary)

                    HStack {
                        Text("120 cm")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                        Text("230 cm")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Step 4: Weight
    private var weightStepView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeader(
                title: "What is your weight?",
                subtitle: "Chef Zest computes your daily protein distribution and macro targets from your weight."
            )

            let heightInM = heightCm / 100.0
            let bmi = weightKg / (heightInM * heightInM)
            let lbs = weightKg * 2.20462

            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(String(format: "%.1f", weightKg))
                            .font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.primary)

                        Text("kg")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    HStack(spacing: 8) {
                        Text("(\(String(format: "%.1f", lbs)) lbs)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)

                        Text("·")
                            .foregroundStyle(AppTheme.textSecondary)

                        Text("BMI: \(String(format: "%.1f", bmi))")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.warmAccent)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.xlarge, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xlarge, style: .continuous)
                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                )

                // Quick Increment Buttons
                HStack(spacing: 16) {
                    metricAdjustButton(icon: "minus", label: "-2kg") {
                        if weightKg > 32 { weightKg -= 2 }
                    }

                    metricAdjustButton(icon: "minus", label: "-0.5kg") {
                        if weightKg > 30.5 { weightKg -= 0.5 }
                    }

                    metricAdjustButton(icon: "plus", label: "+0.5kg") {
                        if weightKg < 199.5 { weightKg += 0.5 }
                    }

                    metricAdjustButton(icon: "plus", label: "+2kg") {
                        if weightKg < 198 { weightKg += 2 }
                    }
                }

                // Slider
                VStack(spacing: 8) {
                    Slider(value: $weightKg, in: 30...200, step: 0.5)
                        .tint(AppTheme.primary)

                    HStack {
                        Text("30 kg")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                        Text("200 kg")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Step 5: Diet Preference
    private var dietStepView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeader(
                title: "What is your diet preference?",
                subtitle: "Strict dietary boundaries enforced across all grocery recommendations and AI recipes."
            )

            VStack(spacing: AppSpacing.md) {
                ForEach(DietaryPreference.allCases) { pref in
                    let isSelected = pref == dietPreference
                    Button {
                        HapticManager.impact(.light)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            dietPreference = pref
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 14) {
                            Image(systemName: pref.badgeIcon)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(isSelected ? AppTheme.primary : AppTheme.textSecondary)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(pref.rawValue)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.textPrimary)

                                Text(pref.description)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .lineSpacing(2)
                            }

                            Spacer(minLength: 0)

                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(isSelected ? AppTheme.primary : AppTheme.borderSubtle)
                        }
                        .padding(AppSpacing.md)
                        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                                .stroke(isSelected ? AppTheme.primary : AppTheme.borderSubtle, lineWidth: isSelected ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Step 6: Health Goal & Macro Summary
    private var goalsStepView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            stepHeader(
                title: "What is your primary goal?",
                subtitle: "We calculate your personalized daily calorie and protein targets."
            )

            VStack(spacing: AppSpacing.md) {
                ForEach(FitnessGoal.allCases) { goal in
                    let isSelected = goal == fitnessGoal
                    Button {
                        HapticManager.impact(.light)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            fitnessGoal = goal
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(goal.rawValue)
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.textPrimary)

                                Text(goalDescription(goal))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }

                            Spacer()

                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(isSelected ? AppTheme.warmAccent : AppTheme.borderSubtle)
                        }
                        .padding(AppSpacing.md)
                        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                                .stroke(isSelected ? AppTheme.warmAccent : AppTheme.borderSubtle, lineWidth: isSelected ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Live Calculated Macro Targets Card
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "bolt.heart.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppTheme.warmAccent)

                    Text("Your Personalized Targets")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Spacer()

                    Text("BMR: \(Int(currentProfile.bmr)) kcal")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                HStack(spacing: AppSpacing.lg) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(currentProfile.calculatedTargetCalories) kcal")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.primary)

                        Text("Daily Calorie Target")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(currentProfile.calculatedTargetProtein)g")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.warmAccent)

                        Text("Daily Protein Goal")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous)
                    .stroke(AppTheme.warmAccent.opacity(0.35), lineWidth: 1.5)
            )
        }
    }

    private func goalDescription(_ goal: FitnessGoal) -> String {
        switch goal {
        case .fatLoss:
            return "Caloric deficit (-20%) optimized for healthy fat burn"
        case .muscleGain:
            return "Caloric surplus (+15%) paired with high protein"
        case .maintenance:
            return "Even balance to stay energized and fit"
        case .zeroWaste:
            return "Maximize pantry shelf-life & zero food waste"
        }
    }

    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Button {
                advanceStep()
            } label: {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView()
                            .tint(AppTheme.elevatedSurface)
                    } else {
                        Text(currentStep == totalSteps ? "Save & Enter Kitchen" : "Continue")
                            .font(.system(size: 17, weight: .bold, design: .rounded))

                        Image(systemName: currentStep == totalSteps ? "checkmark.circle.fill" : "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .foregroundStyle(AppTheme.elevatedSurface)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.primary, in: RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))
                .shadow(color: AppTheme.primary.opacity(0.3), radius: 10, y: 5)
            }
            .disabled(isSaving)
            .buttonStyle(.plain)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
        }
        .background(
            LinearGradient(
                colors: [AppTheme.background.opacity(0), AppTheme.background, AppTheme.background],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func advanceStep() {
        HapticManager.impact(.medium)
        if currentStep < totalSteps {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentStep += 1
            }
        } else {
            completeSetup()
        }
    }

    private func completeSetup() {
        guard !isSaving else { return }
        isSaving = true

        let completedProfile = currentProfile

        Task {
            // Persist profile to Firestore
            do {
                try await FirebaseService.shared.saveUserProfile(completedProfile)
            } catch {
                print("Failed to save user profile to Firebase: \(error.localizedDescription)")
            }

            // Update local store & session
            await MainActor.run {
                store.setProfile(completedProfile)
                sessionManager.markProfileCompleted(with: completedProfile)
                isSaving = false
                router.completeProfileSetup(needsPantrySeed: needsPantrySeed)
            }
        }
    }

    // MARK: - Helpers
    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text(subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(2)
        }
    }

    private func metricAdjustButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.impact(.light)
            action()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                Text(label)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .foregroundStyle(AppTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
