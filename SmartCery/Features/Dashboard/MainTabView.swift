//
//  MainTabView.swift
//
//  This view relies on AppTheme tokens for consistent colors across the app.
//  It assumes that GroceryMarketView, DashboardView, PantryView, GroceryListView, SettingsView,
//  and GroceryMarketViewModel exist elsewhere in the project.
//
//  NOTE: The MainTab enum should include a case .mealPlanner for the new tab to work correctly.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var groceryMarketVM = GroceryMarketViewModel()
    @StateObject private var tabRouter = TabRouter()

    init() {
        // Configure UITabBar appearance if needed, e.g.:
        // UITabBar.appearance().backgroundColor = UIColor(AppTheme.backgroundColor)
    }

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
                GroceryListView()
            }
            .tabItem {
                Label("List", systemImage: "checklist")
            }
            .tag(MainTab.groceryList)

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
