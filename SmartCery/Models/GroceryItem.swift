//
//  GroceryItem.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import Foundation

struct GroceryItem: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var quantity: String
    var isChecked: Bool
    var createdAt: Date

    init(id: UUID = UUID(), name: String, quantity: String = "1", isChecked: Bool = false, createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.isChecked = isChecked
        self.createdAt = createdAt
    }
}
