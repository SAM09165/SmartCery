//
//  DashboardViewModel.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import Foundation
internal import Combine

struct DashboardStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let iconName: String
}

@MainActor
final class DashboardViewModel: ObservableObject {
    let greeting = "Hey, kitchen main character."
    let chefLine = "Chef Zest report: your pantry is currently giving mystery box energy. Set it up before dinner becomes cereal again."

    let stats: [DashboardStat] = [
        DashboardStat(title: "Pantry", value: "0 items", iconName: "cabinet.fill"),
        DashboardStat(title: "Expiring", value: "--", iconName: "clock.badge.exclamationmark.fill"),
        DashboardStat(title: "List", value: "Empty", iconName: "cart.fill")
    ]
}
