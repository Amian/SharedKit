import SwiftUI

struct OnboardingOptionRow: View {
    @Environment(\.colorScheme) private var colorScheme

    let option: OnboardingOption
    let isSelected: Bool
    let accentColor: Color
    let allowsMultipleSelection: Bool

    private var titleColor: Color {
        colorScheme == .dark ? .white : .black
    }

    private var subtitleColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7)
    }

    var body: some View {
        HStack(spacing: 12) {
            if let iconName = option.iconName {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(option.iconColor ?? accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(option.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(titleColor)

                if let subtitle = option.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(subtitleColor)
                        .lineLimit(nil)
                }
            }

            Spacer()

            if allowsMultipleSelection {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? accentColor : subtitleColor)
            } else {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? accentColor : subtitleColor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
        )
    }
}
