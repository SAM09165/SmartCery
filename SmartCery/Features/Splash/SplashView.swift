//
//  SplashView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var router: AppRouter

    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var textOffset: CGFloat = 8
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            AppTheme.deepBasil
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                GroceryLogoMark()
                    .frame(width: 112, height: 112)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                VStack(spacing: 6) {
                    Text("SmartCery")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(AppTheme.textOnDark)

                    Text("Your kitchen, sorted.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(AppTheme.textOnDark.opacity(0.65))
                }
                .offset(y: textOffset)
                .opacity(textOpacity)

                Spacer()
                Spacer()
            }
        }
        .task {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            try? await Task.sleep(nanoseconds: 400_000_000)

            withAnimation(.easeOut(duration: 0.4)) {
                textOffset = 0
                textOpacity = 1
            }

            await router.resolveDestination()
        }
    }
}

private struct GroceryLogoMark: View {
    private let cream = AppTheme.cream
    private let basilGreen = AppTheme.basilGreen
    private let freshGreen = AppTheme.freshGreen

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(cream)
                .shadow(color: .black.opacity(0.16), radius: 18, x: 0, y: 12)

            Image(systemName: "cart.fill")
                .font(.system(size: 50, weight: .bold))
                .foregroundStyle(basilGreen)
                .offset(y: 7)

            Image(systemName: "leaf.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(freshGreen)
                .rotationEffect(.degrees(-18))
                .offset(x: 23, y: -25)

            Image(systemName: "sparkles")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(freshGreen)
                .offset(x: -28, y: -27)
        }
        .accessibilityLabel("SmartCery grocery logo")
    }
}

#Preview {
    SplashView()
        .environmentObject(AppRouter())
}
