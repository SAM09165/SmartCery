//
//  SmartCeryApp.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

@main
struct SmartCeryApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
                .environmentObject(store)
        }
    }
}
