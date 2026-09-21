import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var sessionManager: SessionManager

    let needsPantrySeed: Bool

    @State private var displayName: String = ""
    @State private var age: Int = 25
    @State private var gender: String = "Male"
    @State private var heightCm: Double = 172.0
    @State private var weightKg: Double = 68.0
    @State private var dietPreference: DietaryPreference = .pureVeg
    @State private var workoutFrequency: WorkoutFrequency = .moderate
    @State private var fitnessGoal: FitnessGoal = .fatLoss
    @State private var isScrolled = false

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
            fitnessGoal: fitnessGoal
        )
    }

    var body: some View {
        ZStack {
            AppTheme.softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("profileSetupScroll")).minY
                        )
                    }
                    .frame(height: 0)

                    headerBlock
                    calculatedMacrosBanner
                    bodyMetricsCard
                    dietPreferenceCard
                    workoutCard
                    goalCard
                    saveButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
            .coordinateSpace(name: "profileSetupScroll")
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
                    title: "Personal Health Setup",
                    subtitle: "Strict diet & macro plan setup",
                    isScrolled: isScrolled
                )
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

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tell Chef Zest About Yourself")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.basilGreen)

            Text("We customize meal plans, grocery recommendations, and strict dietary boundaries based on your personal metrics.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(AppTheme.basilGreen.opacity(0.68))
                .lineSpacing(2)
        }
    }

    private var calculatedMacrosBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bolt.heart.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppTheme.zestOrange)

                Text("Calculated Macro Targets")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.zestOrange)

                Spacer()

                Text("BMR: \(Int(currentProfile.bmr)) kcal")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen.opacity(0.6))
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(currentProfile.calculatedTargetCalories) kcal")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(AppTheme.basilGreen)

                    Text("Daily Calorie Target")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.basilGreen.opacity(0.65))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(currentProfile.calculatedTargetProtein)g")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(AppTheme.zestOrange)

                    Text("Daily Protein Goal")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.basilGreen.opacity(0.65))
                }
            }
        }
        .padding(16)
        .background(AppTheme.cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.zestOrange.opacity(0.3), lineWidth: 1.2)
        }
    }

    private var bodyMetricsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Body Metrics")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppTheme.basilGreen)

            HStack(spacing: 12) {
                metricStepper("Age", value: "\(age) yrs") {
                    if age > 12 { age -= 1 }
                } onPlus: {
                    if age < 90 { age += 1 }
                }

                metricStepper("Height", value: "\(Int(heightCm)) cm") {
                    if heightCm > 120 { heightCm -= 1 }
                } onPlus: {
                    if heightCm < 220 { heightCm += 1 }
                }

                metricStepper("Weight", value: "\(Int(weightKg)) kg") {
                    if weightKg > 35 { weightKg -= 1 }
                } onPlus: {
                    if weightKg < 200 { weightKg += 1 }
                }
            }

            HStack(spacing: 10) {
                Text("Gender:")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen)

                ForEach(["Male", "Female", "Other"], id: \.self) { item in
                    let isSelected = gender == item
                    Button {
                        gender = item
                    } label: {
                        Text(item)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(isSelected ? AppTheme.cream : AppTheme.basilGreen)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(isSelected ? AppTheme.basilGreen : AppTheme.cream, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func metricStepper(_ title: String, value: String, onMinus: @escaping () -> Void, onPlus: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppTheme.basilGreen.opacity(0.6))

            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppTheme.basilGreen)

            HStack(spacing: 8) {
                Button(action: onMinus) {
                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppTheme.basilGreen)
                        .frame(width: 26, height: 26)
                        .background(AppTheme.cream, in: Circle())
                }
                .buttonStyle(.plain)

                Button(action: onPlus) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppTheme.cream)
                        .frame(width: 26, height: 26)
                        .background(AppTheme.zestOrange, in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(AppTheme.cream, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var dietPreferenceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "shield.fill")
                    .foregroundStyle(AppTheme.zestOrange)

                Text("Strict Dietary Preference (India Rules)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppTheme.basilGreen)
            }

            VStack(spacing: 10) {
                ForEach(DietaryPreference.allCases) { pref in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            dietPreference = pref
                        }
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: pref == dietPreference ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(pref == dietPreference ? AppTheme.zestOrange : AppTheme.basilGreen.opacity(0.3))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(pref.rawValue)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(AppTheme.basilGreen)

                                Text(pref.description)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(AppTheme.basilGreen.opacity(0.65))
                                    .lineSpacing(2)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(14)
                        .background(pref == dietPreference ? AppTheme.zestOrange.opacity(0.08) : AppTheme.cream, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(pref == dietPreference ? AppTheme.zestOrange : Color.clear, lineWidth: 1.5)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var workoutCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout & Activity Level")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppTheme.basilGreen)

            VStack(spacing: 8) {
                ForEach(WorkoutFrequency.allCases) { freq in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            workoutFrequency = freq
                        }
                    } label: {
                        HStack {
                            Text(freq.rawValue)
                                .font(.system(size: 14, weight: freq == workoutFrequency ? .bold : .medium))
                                .foregroundStyle(freq == workoutFrequency ? AppTheme.cream : AppTheme.basilGreen)

                            Spacer()

                            if freq == workoutFrequency {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(AppTheme.cream)
                            }
                        }
                        .padding(12)
                        .background(freq == workoutFrequency ? AppTheme.basilGreen : AppTheme.cream, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Primary Health Goal")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppTheme.basilGreen)

            VStack(spacing: 8) {
                ForEach(FitnessGoal.allCases) { goal in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            fitnessGoal = goal
                        }
                    } label: {
                        HStack {
                            Text(goal.rawValue)
                                .font(.system(size: 14, weight: goal == fitnessGoal ? .bold : .medium))
                                .foregroundStyle(goal == fitnessGoal ? AppTheme.cream : AppTheme.basilGreen)

                            Spacer()

                            if goal == fitnessGoal {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(AppTheme.cream)
                            }
                        }
                        .padding(12)
                        .background(goal == fitnessGoal ? AppTheme.zestOrange : AppTheme.cream, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var saveButton: some View {
        Button {
            let p = currentProfile
            store.setProfile(p)
            sessionManager.markPantrySeedCompleted()
            router.completeProfileSetup(needsPantrySeed: needsPantrySeed)
        } label: {
            HStack {
                Text("Save Profile & Continue")
                    .font(.system(size: 17, weight: .bold))

                Image(systemName: "arrow.right")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(AppTheme.cream)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.basilGreen, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileSetupView(needsPantrySeed: true)
        .environmentObject(AppRouter())
        .environmentObject(AppStore())
        .environmentObject(SessionManager())
}
