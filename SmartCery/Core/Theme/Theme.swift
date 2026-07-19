//
//  Theme.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

enum AppTheme {
    static let basilGreen = Color(light: (0.16, 0.36, 0.24), dark: (0.62, 0.82, 0.58))
    static let deepBasil = Color(light: (0.10, 0.24, 0.16), dark: (0.05, 0.12, 0.08))
    static let zestOrange = Color(light: (0.94, 0.43, 0.18), dark: (1.0, 0.56, 0.28))
    static let freshGreen = Color(light: (0.48, 0.70, 0.32), dark: (0.67, 0.88, 0.46))
    static let cream = Color(light: (0.98, 0.95, 0.84), dark: (0.18, 0.22, 0.17))
    static let softCream = Color(light: (1.0, 0.98, 0.91), dark: (0.07, 0.10, 0.08))
    static let elevatedSurface = Color(light: (1.0, 1.0, 0.97), dark: (0.12, 0.16, 0.13))
    static let textOnDark = Color(light: (0.98, 0.95, 0.84), dark: (0.98, 0.95, 0.84))
}

private extension Color {
    init(light: (Double, Double, Double), dark: (Double, Double, Double)) {
        self.init(UIColor { traitCollection in
            let selected = traitCollection.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: selected.0, green: selected.1, blue: selected.2, alpha: 1)
        })
    }
}
