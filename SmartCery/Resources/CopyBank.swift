//
//  CopyBank.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import Foundation

enum CopyBank {
    static let chefZestGreeting = "Chef Zest is online. Your fridge has been warned."

    static let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            iconName: "refrigerator.fill",
            eyebrow: "Pantry Radar",
            title: "Your fridge, but with survival instincts.",
            message: "Track what you have, what is expiring, and what is about to become a science project.",
            chefLine: " That lonely tomato deserves a plan, not emotional damage."
        ),
        OnboardingPage(
            iconName: "fork.knife.circle.fill",
            eyebrow: "Chef Zest",
            title: "Dinner ideas from your actual groceries.",
            message: "Chef Zest looks at your pantry and suggests meals before you panic-order fries again.",
            chefLine: "I can make rice and eggs sound intentional. That is range."
        ),
        OnboardingPage(
            iconName: "cart.badge.plus",
            eyebrow: "Smart Lists",
            title: "Buy what is missing. Skip the chaos aisle.",
            message: "Turn meal plans into grocery lists, catch low-stock items, and stop buying your fifth bottle of ketchup.",
            chefLine: "Your grocery list needs structure. Currently it has side quest energy."
        )
    ]
}
