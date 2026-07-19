//
//  AuthView.swift
//  SmartCery
//
//  Created by Saalim Ajmerwala on 19/07/26.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var focusedField: Field?

    private let basilGreen = AppTheme.basilGreen
    private let zestOrange = AppTheme.zestOrange
    private let cream = AppTheme.cream
    private let softCream = AppTheme.softCream
    private let elevatedSurface = AppTheme.elevatedSurface

    var body: some View {
        ZStack {
            softCream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    logoHeader
                    titleBlock
                    formFields
                    chefStatus
                    actionButtons
                }
                .padding(.horizontal, 24)
                .padding(.top, 34)
                .padding(.bottom, 28)
            }
        }
    }

    private var logoHeader: some View {
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(basilGreen)
                    .frame(width: 56, height: 56)

                Image(systemName: "cart.fill")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundStyle(cream)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("SmartCery")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(basilGreen)

                Text("Chef Zest is watching the fridge.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(basilGreen.opacity(0.68))
            }

            Spacer()
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.title)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(basilGreen)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.subtitle)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(basilGreen.opacity(0.72))
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var formFields: some View {
        VStack(spacing: 14) {
            authField(
                title: "Email",
                systemImage: "envelope.fill",
                text: $viewModel.email,
                prompt: "you@fridge.com",
                field: .email
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .autocorrectionDisabled()

            passwordField
        }
    }

    private func authField(title: String, systemImage: String, text: Binding<String>, prompt: String, field: Field) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(zestOrange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(basilGreen.opacity(0.58))

                TextField(prompt, text: text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(basilGreen)
                    .focused($focusedField, equals: field)
            }
        }
        .padding(16)
        .background(cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(focusedField == field ? zestOrange : .clear, lineWidth: 2)
        }
    }

    private var passwordField: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(zestOrange)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text("Password")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(basilGreen.opacity(0.58))

                SecureField("4+ characters", text: $viewModel.password)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(basilGreen)
                    .focused($focusedField, equals: .password)
            }
        }
        .padding(16)
        .background(cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(focusedField == .password ? zestOrange : .clear, lineWidth: 2)
        }
    }

    private var chefStatus: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(zestOrange)

            Text(viewModel.statusMessage)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(basilGreen)
                .lineSpacing(2)

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(elevatedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var actionButtons: some View {
        VStack(spacing: 14) {
            Button {
                if viewModel.submit() {
                    router.completeMockAuth()
                }
            } label: {
                HStack {
                    Text(viewModel.primaryButtonTitle)
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(cream)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(basilGreen, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            Button(viewModel.toggleTitle) {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                    viewModel.toggleMode()
                }
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(zestOrange)

            Button("Continue offline") {
                router.continueOffline()
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(basilGreen.opacity(0.62))
        }
    }
}

private enum Field {
    case email
    case password
}

#Preview {
    AuthView()
        .environmentObject(AppRouter())
}
