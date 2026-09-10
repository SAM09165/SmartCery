//
//  PantryItem.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import Foundation

/// A pantry item stored on-device. Dates are optional because shelf-stable items
/// do not always have an expiry date worth tracking.
struct PantryItem: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var category: String
    var quantity: String
    var expiryDate: Date?
    var iconName: String

    init(id: UUID = UUID(), name: String, category: String, quantity: String = "1 item", expiryDate: Date? = nil, iconName: String = "cabinet.fill") {
        self.id = id
        self.name = name
        self.category = category
        self.quantity = quantity
        self.expiryDate = expiryDate
        self.iconName = iconName
    }
}
