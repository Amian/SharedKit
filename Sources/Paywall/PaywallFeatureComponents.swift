import SwiftUI

struct CompactFeatureRow: View {
    @Environment(\.colorScheme) private var colorScheme

    let feature: PaywallFeature

    private var titleColor: Color { colorScheme == .dark ? .white : .black }
    private var subtitleColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(feature.color.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: feature.icon)
                    .font(typography.iconLarge)
                    .foregroundColor(feature.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(typography.headingLarge)
                    .foregroundColor(titleColor)

                if let subtitle = feature.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(typography.headingSmall)
                        .foregroundColor(subtitleColor)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(typography.iconLarge)
                .foregroundColor(.green)
                .padding(.top, 4)
        }
        .padding(.vertical, 6)
    }
}
