//
//  MainTabView.swift
//  SmartCery
//
//  This view relies on AppTheme tokens for consistent colors across the app.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var groceryMarketVM = GroceryMarketViewModel()
    @StateObject private var tabRouter = TabRouter()

    var body: some View {
        TabView(selection: $tabRouter.selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }
            .tag(MainTab.dashboard)

            NavigationStack {
                GroceryMarketView()
                    .environmentObject(groceryMarketVM)
            }
            .tabItem {
                Label("Market", systemImage: "cart")
            }
            .badge(groceryMarketVM.cartCount)
            .tag(MainTab.market)

            NavigationStack {
                PantryView()
            }
            .tabItem {
                Label("Pantry", systemImage: "archivebox")
            }
            .tag(MainTab.pantry)

            NavigationStack {
                MealPlannerview()
                    .environmentObject(groceryMarketVM)
            }
            .tabItem {
                Label("Planner", systemImage: "calendar")
            }
            .tag(MainTab.mealPlanner)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("More", systemImage: "ellipsis.circle")
            }
            .tag(MainTab.settings)
        }
        .environmentObject(tabRouter)
        .tint(AppTheme.zestOrange)
        .background(AppTheme.softCream.ignoresSafeArea())
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppRouter())
        .environmentObject(AppStore())
}
