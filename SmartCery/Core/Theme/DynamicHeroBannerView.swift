//
//  DynamicHeroBannerView.swift
//  SmartCery
//
//  Premium Dynamic Hero Media Banner for Home Screen.
//  Media background extends into the upper safe area, while promotional content
//  (badge, headline, subtitle, CTA) remains safely contained in dedicated safe region
//  below the floating top bar with zero text overflow across all iPhone models.
//

import SwiftUI

struct DynamicHeroBannerView: View {
    var userProfile: UserProfile = UserProfile()
    var topSafeAreaInset: CGFloat = 47
    var topBarClearance: CGFloat = 64
    var onSelectCategory: ((String) -> Void)? = nil
    var onSelectPromotion: ((HeroPromotion) -> Void)? = nil

    @State private var activeIndex: Int = 0
    @State private var isVisible: Bool = true
    @State private var hasAppeared: Bool = false

    private var promotions: [HeroPromotion] {
        HeroPromotionCatalog.activePromotions(for: userProfile.dietPreference)
    }

    var body: some View {
        VStack(spacing: 0) {
            if !promotions.isEmpty {
                TabView(selection: $activeIndex) {
                    ForEach(Array(promotions.enumerated()), id: \.element.id) { index, promo in
                        bannerSlide(promo: promo, isCurrent: index == activeIndex)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: bannerHeight)
                .clipShape(
                    UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 30, bottomTrailingRadius: 30, topTrailingRadius: 0, style: .continuous)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 6)
            }
        }
        .onAppear {
            isVisible = true
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                hasAppeared = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }

    private var bannerHeight: CGFloat {
        let screenH = UIScreen.main.bounds.height
        // 34-40% of standard viewport including top safe area clearance
        return max(340, min(410, screenH * 0.38))
    }

    // MARK: - Individual Promotional Slide
    private func bannerSlide(promo: HeroPromotion, isCurrent: Bool) -> some View {
        ZStack(alignment: .bottomLeading) {
            // LAYER 1: BASE MEDIA (EXTENDS INTO SAFE AREA)
            ZStack {
                promo.backgroundGradient

                if isVisible {
                    LoopingVideoPlayerView(
                        videoURL: promo.videoURL,
                        localResourceName: promo.localVideoName,
                        posterImageName: promo.posterImage,
                        fallbackImageName: promo.imageFallback,
                        isPlaying: isVisible && isCurrent
                    )
                }
            }

            // LAYER 2: CINEMATIC MULTI-STOP CONTRAST GRADIENT
            LinearGradient(
                stops: [
                    .init(color: Color.black.opacity(0.48), location: 0.0),
                    .init(color: Color.black.opacity(0.08), location: 0.30),
                    .init(color: Color.black.opacity(0.62), location: 0.65),
                    .init(color: Color.black.opacity(0.92), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // LAYER 3: PROMOTIONAL FOREGROUND CONTENT (SAFE ZONE)
            VStack(alignment: .leading, spacing: 0) {
                // Clear the top safe area and the floating top bar so text is NEVER underneath
                Spacer()
                    .frame(height: max(topSafeAreaInset + topBarClearance, 106))

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 7) {
                    // Category & Timing Badge
                    HStack(spacing: 5) {
                        Image(systemName: promo.badgeIcon)
                            .font(.system(size: 10, weight: .bold))

                        Text(promo.badgeText.uppercased())
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .tracking(0.8)
                    }
                    .foregroundStyle(promo.accentColor)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.48), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(promo.accentColor.opacity(0.4), lineWidth: 1)
                    )

                    // Main Promotional Headline (Safely constrained, auto-wrapping, zero overflow)
                    Text(promo.title)
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .shadow(color: Color.black.opacity(0.6), radius: 4, x: 0, y: 2)

                    // Subtitle / Express Delivery Value Proposition
                    Text(promo.subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.90))
                        .lineLimit(2)
                        .minimumScaleFactor(0.90)
                        .lineSpacing(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

                    // Bottom Row: CTA Button + Pagination Dots
                    HStack(alignment: .center, spacing: 12) {
                        Button {
                            HapticManager.impact(.medium)
                            onSelectPromotion?(promo)
                            onSelectCategory?(promo.destinationCategory)
                        } label: {
                            HStack(spacing: 6) {
                                Text(promo.ctaText)
                                    .font(.system(size: 13, weight: .bold, design: .rounded))

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 11, weight: .black))
                            }
                            .foregroundStyle(Color(red: 0.12, green: 0.15, blue: 0.13))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(Color.white, in: Capsule())
                            .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)

                        Spacer(minLength: 8)

                        // Minimal Pagination Dots in bottom row
                        if promotions.count > 1 {
                            HStack(spacing: 5) {
                                ForEach(0..<promotions.count, id: \.self) { idx in
                                    Capsule()
                                        .fill(idx == activeIndex ? Color.white : Color.white.opacity(0.35))
                                        .frame(width: idx == activeIndex ? 16 : 5, height: 5)
                                        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: activeIndex)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color.black.opacity(0.35), in: Capsule())
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 16)
            }
            .offset(y: hasAppeared ? 0 : 10)
            .opacity(hasAppeared ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.45), value: hasAppeared)
        }
    }
}
