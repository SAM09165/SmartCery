//
//  MainTabView.swift
//  SmartCery
//
//  Custom floating bottom navigation system with 5 primary tabs:
//  Home, Plan, Shop, Recipes, Profile.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var groceryMarketVM = GroceryMarketViewModel()
    @StateObject private var tabRouter = TabRouter()

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background.ignoresSafeArea()

            Group {
                switch tabRouter.selectedTab {
                case .dashboard:
                    NavigationStack {
                        DashboardView()
                    }
                case .mealPlanner:
                    NavigationStack {
                        MealPlannerview()
                    }
                case .market:
                    NavigationStack {
                        GroceryMarketView()
                    }
                case .recipes:
                    NavigationStack {
                        ChefZestView()
                    }
                case .settings:
                    NavigationStack {
                        SettingsView()
                    }
                case .pantry, .Pantry:
                    NavigationStack {
                        PantryView()
                    }
                case .groceryList:
                    NavigationStack {
                        GroceryListView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Leave breathing room for the floating bottom bar
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 64)
            }

            // Floating Liquid Glass Navigation Bar
            SmartCeryFloatingBottomBar(
                selectedTab: $tabRouter.selectedTab,
                cartCount: groceryMarketVM.cartCount
            )
            .padding(.bottom, 6)
        }
        .environmentObject(groceryMarketVM)
        .environmentObject(tabRouter)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppRouter())
        .environmentObject(AppStore())
        .environmentObject(SessionManager())
}
