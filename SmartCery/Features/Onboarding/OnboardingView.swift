
//
//  OnboardingView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = OnboardingViewModel()

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange
    private let cream = AppTheme.cream
    private let softCream = AppTheme.softCream

    var body: some View {
        ZStack {
            softCream.ignoresSafeArea()

            VStack(spacing: 24) {
                topBar

                TabView(selection: $viewModel.currentPageIndex) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                        onboardingPage(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageDots
                actionBar
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 24)
        }
    }

    private var topBar: some View {
        HStack {
            Label("SmartCery", systemImage: "cart.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(basilGreen)

            Spacer()

            Button("Skip") {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    viewModel.skipToLastPage()
                }
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(basilGreen.opacity(0.7))
            .opacity(viewModel.isLastPage ? 0 : 1)
        }
    }

    private func onboardingPage(_ page: OnboardingPage) -> some View {
        VStack(spacing: 28) {
            Spacer(minLength: 12)

            ZStack {
                Circle()
                    .fill(cream)
                    .frame(width: 188, height: 188)

                Image(systemName: page.iconName)
                    .font(.system(size: 82, weight: .semibold))
                    .foregroundStyle(zestOrange)
                    .symbolRenderingMode(.hierarchical)
            }
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(basilGreen)
                    .padding(18)
                    .background(softCream, in: Circle())
                    .offset(x: 4, y: 2)
            }

            VStack(spacing: 12) {
                Text(page.eyebrow.uppercased())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(zestOrange)

                Text(page.title)
                    .font(.system(size: 32, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(basilGreen)
                    .fixedSize(horizontal: false, vertical: true)

                Text(page.message)
                    .font(.system(size: 16, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(basilGreen.opacity(0.74))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            chefBubble(page.chefLine)

            Spacer(minLength: 8)
        }
    }

    private func chefBubble(_ line: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(zestOrange)

            Text(line)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(basilGreen)
                .lineSpacing(2)

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == viewModel.currentPageIndex ? zestOrange : basilGreen.opacity(0.18))
                    .frame(width: index == viewModel.currentPageIndex ? 26 : 8, height: 8)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.currentPageIndex)
    }

    private var actionBar: some View {
        Button {
            if viewModel.isLastPage {
                router.completeOnboarding()
            } else {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    viewModel.goNext()
                }
            }
        } label: {
            HStack {
                Text(viewModel.primaryButtonTitle)
                    .font(.system(size: 17, weight: .semibold))

                Image(systemName: viewModel.isLastPage ? "fork.knife" : "arrow.right")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(cream)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(basilGreen, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppRouter())
}
