//
//  PantrySeedViewModel.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import Foundation
import Combine

struct PantrySeedItem: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let category: String
    var dietType: MarketItemDiet = .pureVeg
}

@MainActor
final class PantrySeedViewModel: ObservableObject {
    @Published var selectedItemIDs: Set<UUID> = []
    @Published var chefLine = "Tap what is already in your kitchen. Chef Zest will pretend not to judge."
    @Published var activeDiet: DietaryPreference = .pureVeg

    let allItems: [PantrySeedItem] = [
        PantrySeedItem(name: "Fresh Paneer", iconName: "square.fill", category: "Protein", dietType: .pureVeg),
        PantrySeedItem(name: "Milk", iconName: "mug.fill", category: "Dairy", dietType: .pureVeg),
        PantrySeedItem(name: "Rice", iconName: "takeoutbag.and.cup.and.straw.fill", category: "Staple", dietType: .pureVeg),
        PantrySeedItem(name: "Pasta", iconName: "fork.knife", category: "Staple", dietType: .pureVeg),
        PantrySeedItem(name: "Tomatoes", iconName: "circle.fill", category: "Veg", dietType: .pureVeg),
        PantrySeedItem(name: "Onions", iconName: "circle.dashed", category: "Veg", dietType: .pureVeg),
        PantrySeedItem(name: "Bread", iconName: "birthday.cake.fill", category: "Bakery", dietType: .pureVeg),
        PantrySeedItem(name: "Cheese", iconName: "square.fill", category: "Dairy", dietType: .pureVeg),
        PantrySeedItem(name: "Spinach", iconName: "leaf.fill", category: "Veg", dietType: .pureVeg),
        PantrySeedItem(name: "Potatoes", iconName: "circle.grid.2x2.fill", category: "Veg", dietType: .pureVeg),
        PantrySeedItem(name: "Yogurt", iconName: "cup.and.saucer.fill", category: "Dairy", dietType: .pureVeg),
        PantrySeedItem(name: "Dal / Lentils", iconName: "circle.grid.2x2.fill", category: "Protein", dietType: .pureVeg),
        PantrySeedItem(name: "Eggs", iconName: "oval.fill", category: "Protein", dietType: .egg),
        PantrySeedItem(name: "Chicken", iconName: "chicken.fill", category: "Protein", dietType: .nonVeg)
    ]

    var items: [PantrySeedItem] {
        visibleItems
    }

    var visibleItems: [PantrySeedItem] {
        allItems.filter { item in
            switch activeDiet {
            case .pureVeg, .vegan, .jainVeg:
                return item.dietType == .pureVeg
            case .eggitarian:
                return item.dietType == .pureVeg || item.dietType == .egg
            case .nonVeg:
                return true
            }
        }
    }

    func syncDiet(_ diet: DietaryPreference) {
        self.activeDiet = diet
        // If switching to veg, remove any invalid selected items
        if diet.isStrictVeg {
            let invalidIDs = allItems.filter { $0.dietType != .pureVeg }.map(\.id)
            selectedItemIDs.subtract(invalidIDs)
        } else if !diet.allowsMeat {
            let meatIDs = allItems.filter { $0.dietType == .nonVeg }.map(\.id)
            selectedItemIDs.subtract(meatIDs)
        }
    }

    var selectedItems: [PantrySeedItem] {
        allItems.filter { selectedItemIDs.contains($0.id) }
    }

    var selectedCount: Int {
        selectedItemIDs.count
    }

    var primaryButtonTitle: String {
        selectedCount == 0 ? "Skip for Now" : "Save \(selectedCount) Items"
    }

    var subtitle: String {
        selectedCount == 0 ? "Start with the basics. Even two items can become dinner if confidence is high enough." : "Nice. Your pantry is starting to look less like a side quest."
    }

    func isSelected(_ item: PantrySeedItem) -> Bool {
        selectedItemIDs.contains(item.id)
    }

    func toggle(_ item: PantrySeedItem) {
        if selectedItemIDs.contains(item.id) {
            selectedItemIDs.remove(item.id)
        } else {
            selectedItemIDs.insert(item.id)
        }

        updateChefLine()
    }

    func clearSelection() {
        selectedItemIDs.removeAll()
        chefLine = "Clean slate. Bold choice. Slightly suspicious fridge energy."
    }

    func saveSelection() {
        // AppStore performs persistence
    }

    private func updateChefLine() {
        let count = selectedCount
        if count == 0 {
            chefLine = "Zero items selected. Are you living on sunlight and good vibes?"
        } else if count < 3 {
            chefLine = "A minimalist start. Respectable, but dinner might be adventurous."
        } else if count < 6 {
            chefLine = "Solid foundation. Chef Zest can work with this."
        } else {
            chefLine = "Look at you, fully stocked. Almost looks like an adult lives here."
        }
    }
}
