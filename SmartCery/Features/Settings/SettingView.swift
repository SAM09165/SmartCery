//
//  SettingView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        SettingsView()
    }
}

#Preview {
    SettingView()
        .environmentObject(AppRouter())
        .environmentObject(AppStore())
        .environmentObject(SessionManager())
}
