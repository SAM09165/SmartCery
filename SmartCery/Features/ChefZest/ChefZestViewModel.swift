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
    case highProtein = "High Protein"
    case fatLoss = "Fat Loss"
    case muscleGain = "Muscle Gain"
    case zeroWaste = "Zero Waste"
    case lowCarb = "Keto / Low Carb"
    case gutHealth = "Gut Health"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .highProtein: return "figure.strengthtraining.traditional"
        case .fatLoss: return "flame.fill"
        case .muscleGain: return "figure.cooldown"
        case .zeroWaste: return "arrow.triangle.2.circlepath"
        case .lowCarb: return "leaf.fill"
        case .gutHealth: return "heart.fill"
        }
    }

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

                await MainActor.run {
                    self.chatMessages.append(
                        AIDietChatMessage(
                            sender: .chefZest,
                            text: replyText,
                            timestamp: Date(),
                            suggestedRecipe: self.recommendations.first
                        )
                    )
                    self.isThinking = false
                }
            } catch {
                await MainActor.run {
                    let fallback = self.generateFallbackAIResponse(textToSend, pantry: pantry, dietPreference: userDiet)
                    self.chatMessages.append(
                        AIDietChatMessage(
                            sender: .chefZest,
                            text: fallback,
                            timestamp: Date(),
                            suggestedRecipe: self.recommendations.first
                        )
                    )
                    self.isThinking = false
                }
            }
        }
    }

    private func generateFallbackAIResponse(_ prompt: String, pantry: [PantryItem], dietPreference: DietaryPreference) -> String {
        let isStrictVeg = dietPreference.isStrictVeg
        let lower = prompt.lowercased()

        if lower.contains("protein") {
            if isStrictVeg {
                return "For high plant protein, I recommend combining fresh Malai Paneer with sprouted moong or soya chunks. This gives you 35-40g of clean protein with zero cholesterol!"
            } else {
                return "To maximize protein today, pair grilled chicken breast or 3 organic eggs with roasted veggies. This will deliver 45g of bioavailable protein."
            }
        } else if lower.contains("waste") || lower.contains("dinner") {
            return "Check your pantry radar! Items nearing expiration can be sautéed with cumin and turmeric into a delicious zero-waste 10-minute bhurji or wok stir-fry."
        } else {
            return "Balanced nutrition is all about whole foods. Pair 1 portion of protein with 2 portions of fibrous vegetables, and stay well hydrated throughout your day!"
        }
    }
}
