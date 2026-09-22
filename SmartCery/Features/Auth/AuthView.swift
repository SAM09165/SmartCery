import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var sessionManager: SessionManager
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
                VStack(spacing: 20) {
                    heroHeaderCard
                    headlineSection
                    divider("Log in or sign up")
                    inputSection
                    chefStatusBanner
                    primaryButton
                    divider("or")
                    socialAuthRow
                    footerTerms
                }
                .padding(.bottom, 30)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // Top Curved Visual Hero Banner matching Zomato style
    private var heroHeaderCard: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [
                    Color(red: 0.11, green: 0.28, blue: 0.22),
                    basilGreen,
                    Color(red: 0.88, green: 0.42, blue: 0.22)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 250)
            .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 36, bottomTrailingRadius: 36))

            // Background Decorative Culinary Graphics
            HStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 140, height: 140)
                    .offset(x: -30, y: -20)

                Spacer()

                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 180, height: 180)
                    .offset(x: 50, y: 70)
            }
            .frame(height: 250)

            // Top Right Skip Pill Button
            Button {
                router.continueOffline()
            } label: {
                Text("Skip")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(cream)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.22), in: Capsule())
            }
            .padding(.top, 54)
            .padding(.trailing, 20)
            .buttonStyle(.plain)

            // Center Floating Chef Identity
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(cream)
                        .frame(width: 84, height: 84)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, y: 6)

                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(basilGreen)
                }

                Text("SmartCery")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(cream)
                    .tracking(0.5)

                Text("AI ZERO-WASTE & MEAL INTELLIGENCE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(cream.opacity(0.85))
                    .tracking(1.4)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 50)
        }
    }

    // Bold App Headline
    private var headlineSection: some View {
        VStack(spacing: 6) {
            Text(viewModel.title)
                .font(.system(size: 21, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(basilGreen)
                .padding(.horizontal, 24)

            Text(viewModel.subtitle)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(basilGreen.opacity(0.68))
                .padding(.horizontal, 30)
        }
        .padding(.top, 6)
    }

    // Input Fields
    private var inputSection: some View {
        VStack(spacing: 12) {
            if viewModel.inputType == .phone {
                HStack(spacing: 10) {
                    // Country Code Dropdown
                    Menu {
                        ForEach(viewModel.countryCodes, id: \.self) { code in
                            Button(code) {
                                viewModel.selectedCountryCode = code
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedCountryCode)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(basilGreen)

                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(basilGreen.opacity(0.6))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(cream, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(basilGreen.opacity(0.15), lineWidth: 1)
                        }
                    }

                    // Mobile Number Field
                    HStack {
                        TextField("Enter Mobile Number", text: $viewModel.phoneNumber)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(basilGreen)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: .phone)
                    }
                    .padding(14)
                    .background(cream, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(focusedField == .phone ? zestOrange : basilGreen.opacity(0.15), lineWidth: focusedField == .phone ? 2 : 1)
                    }
                }
            } else {
                // Email Field
                HStack(spacing: 12) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(focusedField == .email ? zestOrange : basilGreen.opacity(0.4))

                    TextField("Enter Email Address", text: $viewModel.email)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(basilGreen)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .email)
                }
                .padding(14)
                .background(cream, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(focusedField == .email ? zestOrange : basilGreen.opacity(0.15), lineWidth: focusedField == .email ? 2 : 1)
                }

                // Password Field
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(focusedField == .password ? zestOrange : basilGreen.opacity(0.4))

                    SecureField("Enter Password", text: $viewModel.password)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(basilGreen)
                        .focused($focusedField, equals: .password)
                }
                .padding(14)
                .background(cream, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(focusedField == .password ? zestOrange : basilGreen.opacity(0.15), lineWidth: focusedField == .password ? 2 : 1)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // Status Message
    private var chefStatusBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "flame.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(zestOrange)

            Text(viewModel.statusMessage)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(basilGreen)
                .lineSpacing(2)

            Spacer(minLength: 0)
        }
        .padding(12)
        .padding(.horizontal, 4)
        .padding(.horizontal, 24)
    }

    // Primary Action Button (Zomato-style Continue Button)
    private var primaryButton: some View {
        Button {
            Task {
                guard let record = await viewModel.submit() else { return }
                sessionManager.applySignedInRecord(record)
                store.setProfile(record.profile)

                if !record.hasCompletedProfile {
                    router.openProfileSetup(needsPantrySeed: !record.hasCompletedPantrySeed)
                } else {
                    router.completeAuth(needsPantrySeed: !record.hasCompletedPantrySeed)
                }
            }
        } label: {
            HStack {
                if viewModel.isSubmitting {
                    ProgressView()
                        .tint(cream)
                } else {
                    Text(viewModel.primaryButtonTitle)
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .foregroundStyle(cream)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(zestOrange, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: zestOrange.opacity(0.35), radius: 8, y: 4)
        }
        .disabled(viewModel.isSubmitting)
        .padding(.horizontal, 24)
        .buttonStyle(.plain)
    }

    // Social Sign-In Row matching reference (Google, Apple, Phone/Email toggle)
    private var socialAuthRow: some View {
        VStack(spacing: 14) {
            HStack(spacing: 16) {
                // Google Button
                socialIconButton(iconName: "g.circle.fill", color: Color.red) {
                    viewModel.inputType = .email
                }

                // Apple Button
                socialIconButton(iconName: "applelogo", color: Color.black) {
                    viewModel.inputType = .email
                }

                // Switch Phone/Email Button
                socialIconButton(
                    iconName: viewModel.inputType == .email ? "phone.fill" : "envelope.fill",
                    color: basilGreen
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        viewModel.inputType = (viewModel.inputType == .email) ? .phone : .email
                    }
                }
            }

            // Mode Toggle (New here? Create an account / Already have an account? Log in)
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    viewModel.toggleMode()
                }
            } label: {
                Text(viewModel.toggleTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(zestOrange)
            }
            .padding(.top, 4)
        }
    }

    private func socialIconButton(iconName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(cream)
                    .frame(width: 52, height: 52)
                    .shadow(color: Color.black.opacity(0.06), radius: 6, y: 3)
                    .overlay {
                        Circle().stroke(basilGreen.opacity(0.12), lineWidth: 1)
                    }

                Image(systemName: iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .buttonStyle(.plain)
    }

    private func divider(_ text: String) -> some View {
        HStack {
            Rectangle()
                .fill(basilGreen.opacity(0.12))
                .frame(height: 1)

            Text(text.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(basilGreen.opacity(0.5))
                .padding(.horizontal, 8)

            Rectangle()
                .fill(basilGreen.opacity(0.12))
                .frame(height: 1)
        }
        .padding(.horizontal, 28)
    }

    private var footerTerms: some View {
        Text("By continuing, you agree to our Terms of Service & Privacy Policy.")
            .font(.system(size: 11, weight: .regular))
            .multilineTextAlignment(.center)
            .foregroundStyle(basilGreen.opacity(0.5))
            .padding(.horizontal, 32)
            .padding(.top, 8)
    }

    enum Field: Hashable {
        case email, password, phone
    }
}
