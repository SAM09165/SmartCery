import SwiftUI

struct SkeletalLoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<4, id: \.self) { _ in
                skeletonCard
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }

    private var skeletonCard: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(shimmerGradient)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(shimmerGradient)
                    .frame(width: 140, height: 16)

                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(shimmerGradient)
                    .frame(width: 90, height: 12)
            }

            Spacer()

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(shimmerGradient)
                .frame(width: 60, height: 28)
        }
        .padding(14)
        .background(AppTheme.cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            colors: [
                AppTheme.basilGreen.opacity(0.08),
                AppTheme.zestOrange.opacity(0.2),
                AppTheme.basilGreen.opacity(0.08)
            ],
            startPoint: isAnimating ? .trailing : .leading,
            endPoint: isAnimating ? .leading : .trailing
        )
    }
}

#Preview {
    SkeletalLoadingView()
        .padding()
        .background(AppTheme.softCream)
}
