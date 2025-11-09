import SwiftUI

struct CompactFeatureCard: View {
    let feature: PremiumFeature

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(feature.color.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: feature.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(feature.color)
            }

            VStack(spacing: 2) {
                Text(feature.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(feature.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct CompactFeatureRow: View {
    let feature: PremiumFeature

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(feature.color.opacity(0.15))
                    .frame(width: 24, height: 24)

                Image(systemName: feature.icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(feature.color)
            }

            Text(feature.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(feature.color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
