import SwiftUI

struct ChefZestView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChefZestViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.softCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        hero
                        suggestionsSection
                        recommendationsSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Chef Zest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear(perform: refresh)
        .onChange(of: store.pantry) { _, _ in refresh() }
        .onChange(of: store.groceryList) { _, _ in refresh() }
    }

    private var hero: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.zestOrange)
                .frame(width: 44, height: 44)
                .background(AppTheme.cream, in: Circle())

            VStack(alignment: .leading, spacing: 7) {
                Text(viewModel.headline)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen)
                    .fixedSize(horizontal: false, vertical: true)

                Text(viewModel.subheadline)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppTheme.basilGreen.opacity(0.66))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Smart grocery adds")

            if viewModel.grocerySuggestions.isEmpty {
                compactStatusCard(
                    iconName: "checkmark.circle.fill",
                    title: "No gaps found",
                    message: store.pantry.isEmpty ? "Add pantry items first." : "Your grocery list already covers the top recipe gaps."
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.grocerySuggestions, id: \.self) { item in
                        Button {
                            store.addGroceryItem(name: item)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(AppTheme.zestOrange)
                                    .frame(width: 34, height: 34)
                                    .background(AppTheme.cream, in: Circle())

                                Text(item)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(AppTheme.basilGreen)

                                Spacer(minLength: 0)

                                Text("Add")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(AppTheme.zestOrange)
                            }
                            .padding(14)
                            .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Meals to cook")

            if viewModel.recommendations.isEmpty {
                compactStatusCard(
                    iconName: "cabinet.fill",
                    title: "Pantry is empty",
                    message: "Add a few ingredients and Chef Zest will match meals automatically."
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.recommendations) { recommendation in
                        recommendationCard(recommendation)
                    }
                }
            }
        }
    }

    private func recommendationCard(_ recommendation: PantryRecipeRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: recommendation.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppTheme.zestOrange)
                    .frame(width: 42, height: 42)
                    .background(AppTheme.cream, in: Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text("\(recommendation.matchScore)% pantry match")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.zestOrange)

                    Text(recommendation.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppTheme.basilGreen)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(recommendation.summary)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(AppTheme.basilGreen.opacity(0.64))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            Label(recommendation.priorityReason, systemImage: "lightbulb.fill")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.basilGreen)

            HStack(spacing: 8) {
                metricPill(recommendation.cookTime, iconName: "clock")
                metricPill(recommendation.difficulty, iconName: "gauge.with.dots.needle.bottom.50percent")
            }

            chipLine(title: "Uses", items: recommendation.usesPantry, color: AppTheme.basilGreen)

            if !recommendation.missingItems.isEmpty {
                chipLine(title: "Needs", items: recommendation.missingItems, color: AppTheme.zestOrange)
            }
        }
        .padding(16)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func compactStatusCard(iconName: String, title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.zestOrange)
                .frame(width: 38, height: 38)
                .background(AppTheme.cream, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppTheme.basilGreen)

                Text(message)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(AppTheme.basilGreen.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func metricPill(_ text: String, iconName: String) -> some View {
        Label(text, systemImage: iconName)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(AppTheme.basilGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.cream, in: Capsule())
    }

    private func chipLine(title: String, items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(color)

            FlexibleChipLayout(spacing: 6) {
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

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(AppTheme.basilGreen)
    }

    private func refresh() {
        viewModel.refresh(pantry: store.pantry, groceryList: store.groceryList)
    }
}

private struct FlexibleChipLayout<Content: View>: View {
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

#Preview {
    ChefZestView()
        .environmentObject(AppStore())
}
