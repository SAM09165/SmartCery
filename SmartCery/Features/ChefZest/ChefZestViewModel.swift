import Foundation
import Combine

struct AIDietChatMessage: Identifiable, Hashable {
    let id = UUID()
    let sender: MessageSender
    let text: String
    let timestamp: Date
    let suggestedRecipe: PantryRecipeRecommendation?

    enum MessageSender {
        case user, chefZest
    }
}

enum DietGoal: String, CaseIterable, Identifiable {
    case highProtein = "High Protein 💪"
    case fatLoss = "Fat Loss 🔥"
    case muscleGain = "Muscle Gain 🏋️‍♂️"
    case zeroWaste = "Zero Waste ♻️"
    case lowCarb = "Keto / Low Carb 🥑"
    case gutHealth = "Gut Health 🥗"

    var id: String { rawValue }

    var targetCalories: Int {
        switch self {
        case .highProtein: return 2100
        case .fatLoss: return 1750
        case .muscleGain: return 2600
        case .zeroWaste: return 1900
        case .lowCarb: return 1800
        case .gutHealth: return 1950
        }
    }

    var targetProteinGrams: Int {
        switch self {
        case .highProtein: return 145
        case .fatLoss: return 130
        case .muscleGain: return 165
        case .zeroWaste: return 100
        case .lowCarb: return 120
        case .gutHealth: return 110
        }
    }
}

@MainActor
final class ChefZestViewModel: ObservableObject {
    @Published private(set) var recommendations: [PantryRecipeRecommendation] = []
    @Published private(set) var grocerySuggestions: [String] = []
    @Published var selectedDietGoal: DietGoal = .highProtein
    @Published var chatMessages: [AIDietChatMessage] = []
    @Published var isThinking: Bool = false
    @Published var userPromptText: String = ""

    private var geminiService = GeminiService()

    init() {
        chatMessages = [
            AIDietChatMessage(
                sender: .chefZest,
                text: "Namaste! I am Chef Zest, your AI Dietitian & Zero-Waste Personal Assistant. I strictly enforce your Veg / Non-Veg dietary boundary. How can I assist your nutrition goals today?",
                timestamp: Date(),
                suggestedRecipe: nil
            )
        ]
    }

    var headline: String {
        "Chef Zest • AI Personal Dietitian"
    }

    var subheadline: String {
        "Target: \(selectedDietGoal.targetCalories) kcal • \(selectedDietGoal.targetProteinGrams)g Protein. Tailored to your strict diet & pantry."
    }

    func refresh(pantry: [PantryItem], groceryList: [GroceryItem], profile: UserProfile? = nil) {
        let userDiet = profile?.dietPreference ?? .pureVeg
        let matched = PantryMatcher.recommendations(for: pantry, dietPreference: userDiet)

        switch selectedDietGoal {
        case .highProtein:
            recommendations = matched.sorted(by: { $0.proteinGrams > $1.proteinGrams })
        case .fatLoss:
            recommendations = matched.sorted(by: { $0.calories < $1.calories })
        case .zeroWaste:
            recommendations = matched.sorted(by: { $0.matchScore > $1.matchScore })
        default:
            recommendations = matched
        }

        grocerySuggestions = GroceryListGenerator.missingIngredients(
            from: recommendations,
            existingGroceryItems: groceryList
        )
    }

    func sendUserMessage(_ customPrompt: String? = nil, pantry: [PantryItem], profile: UserProfile? = nil) {
        let textToSend = customPrompt ?? userPromptText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty else { return }

        userPromptText = ""

        let userMsg = AIDietChatMessage(sender: .user, text: textToSend, timestamp: Date(), suggestedRecipe: nil)
        chatMessages.append(userMsg)

        isThinking = true

        let userDiet = profile?.dietPreference ?? .pureVeg

        Task {
            let pantryNames = pantry.map { "\($0.name) (\($0.quantity))" }.joined(separator: ", ")
            let prompt = """
            You are Chef Zest, a warm, highly encouraging AI Dietitian and Zero-Waste Chef.
            STRICT RULE: The user is strictly \(userDiet.rawValue) (\(userDiet.description)).
            NEVER recommend non-veg, eggs, or meat if user is Strict Pure Veg, Vegan, or Jain Veg!

            The user says: "\(textToSend)".
            User's Current Diet Goal: \(selectedDietGoal.rawValue) (\(selectedDietGoal.targetCalories) kcal, \(selectedDietGoal.targetProteinGrams)g Protein).
            Pantry Ingredients available: \(pantryNames.isEmpty ? "None listed yet" : pantryNames).

            Give a concise, actionable, high-protein advice or 1-minute zero-waste recipe recommendation matching user's strict diet. Keep under 3 short paragraphs.
            """

            do {
                let aiResponse = try await geminiService.generateText(prompt: prompt)
                let replyText = aiResponse.isEmpty ? generateFallbackAIResponse(textToSend, pantry: pantry, dietPreference: userDiet) : aiResponse

                let botMsg = AIDietChatMessage(sender: .chefZest, text: replyText, timestamp: Date(), suggestedRecipe: recommendations.first)
                chatMessages.append(botMsg)
            } catch {
                let replyText = generateFallbackAIResponse(textToSend, pantry: pantry, dietPreference: userDiet)
                let botMsg = AIDietChatMessage(sender: .chefZest, text: replyText, timestamp: Date(), suggestedRecipe: recommendations.first)
                chatMessages.append(botMsg)
            }

            isThinking = false
        }
    }

    private func generateFallbackAIResponse(_ prompt: String, pantry: [PantryItem], dietPreference: DietaryPreference) -> String {
        let pantryList = pantry.map(\.name).joined(separator: ", ")

        if dietPreference.isStrictVeg {
            if prompt.lowercased().contains("protein") {
                return "For a strict Pure Veg target of \(selectedDietGoal.targetProteinGrams)g protein, I recommend combining paneer, chickpeas, sprouted moong, or lentils. A Paneer Spinach Scramble or Sprouted Moong Bowl yields 26g high-quality plant protein!"
            } else if prompt.lowercased().contains("waste") || prompt.lowercased().contains("expiring") {
                return "Zero-waste Veg Tip: Turn any expiring vegetables into a warm stir-fry or rustic tomato-lentil soup. Using \(pantryList.isEmpty ? "your pantry stock" : pantryList) preserves nutrients and saves food."
            } else {
                return "As a Strict Pure Veg user, prioritize whole grains, paneer, tofu, legumes, and green leafy vegetables. You can easily build balanced bowls with your kitchen stock!"
            }
        } else {
            if prompt.lowercased().contains("protein") {
                return "To reach your \(selectedDietGoal.targetProteinGrams)g protein target, combine eggs, paneer, or lean protein with complex carbs. An Egg Spinach Scramble gives you 22g protein in 10 minutes!"
            } else {
                return "Great choice! Prioritize whole foods, lean proteins, and nutrient-dense greens for your \(selectedDietGoal.rawValue) target."
            }
        }
    }
}
