//
//  PantrySeedViewModel.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import Foundation
internal import Combine

struct PantrySeedItem: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let category: String
}

@MainActor
final class PantrySeedViewModel: ObservableObject {
    @Published var selectedItemIDs: Set<UUID> = []
    @Published var chefLine = "Tap what is already in your kitchen. Chef Zest will pretend not to judge."

    let items: [PantrySeedItem] = [
        PantrySeedItem(name: "Eggs", iconName: "oval.fill", category: "Protein"),
        PantrySeedItem(name: "Milk", iconName: "mug.fill", category: "Dairy"),
        PantrySeedItem(name: "Rice", iconName: "takeoutbag.and.cup.and.straw.fill", category: "Staple"),
        PantrySeedItem(name: "Pasta", iconName: "fork.knife", category: "Staple"),
        PantrySeedItem(name: "Tomatoes", iconName: "circle.fill", category: "Veg"),
        PantrySeedItem(name: "Onions", iconName: "circle.dashed", category: "Veg"),
        PantrySeedItem(name: "Bread", iconName: "birthday.cake.fill", category: "Bakery"),
        PantrySeedItem(name: "Cheese", iconName: "square.fill", category: "Dairy"),
        PantrySeedItem(name: "Chicken", iconName: "chicken.fill", category: "Protein"),
        PantrySeedItem(name: "Spinach", iconName: "leaf.fill", category: "Veg"),
        PantrySeedItem(name: "Potatoes", iconName: "circle.grid.2x2.fill", category: "Veg"),
        PantrySeedItem(name: "Yogurt", iconName: "cup.and.saucer.fill", category: "Dairy")
    ]

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
        // TODO: Save selected pantry seed items to SwiftData later.
    }

    private func updateChefLine() {
        switch selectedCount {
        case 0:
            chefLine = "Tap what is already in your kitchen. Chef Zest will pretend not to judge."
        case 1...3:
            chefLine = "Okay, tiny pantry starter pack. We can work with this."
        case 4...7:
            chefLine = "Now we are cooking. Literally, that is the whole point."
        default:
            chefLine = "Look at you, grocery main character. The fridge has lore now."
        }
    }
}
