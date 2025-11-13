import SwiftUI
import DesignSystem

@available(iOS 17.0, macOS 11.0, *)
struct OnboardingOptionRow: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.designTypography) private var typography

    let option: OnboardingOption
    let isSelected: Bool
    let accentColor: Color
    let allowsMultipleSelection: Bool

    var body: some View {
        let cornerRadius: CGFloat = 16

        HStack(spacing: 10) {
            if let iconName = option.iconName {
                iconView(systemName: iconName)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(option.title)
                    .font(typography.listTitle)
                    .foregroundColor(titleColor)

                if let subtitle = option.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(typography.listSubtitle)
                        .foregroundColor(subtitleColor)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 8)

            selectionIndicator
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            isSelected ? accentColor : Color.black.opacity(colorScheme == .dark ? 0.15 : 0.05),
                            lineWidth: 1.5
                        )
                )
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.5 : 0.06),
                    radius: 20,
                    x: 0,
                    y: 10
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(selectedOverlay(cornerRadius: cornerRadius))
    }

    private var titleColor: Color {
        colorScheme == .dark ? Color.white : Color(red: 15/255, green: 23/255, blue: 42/255)
    }

    private var subtitleColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.75) : Color(red: 71/255, green: 85/255, blue: 105/255)
    }

    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 19/255, green: 23/255, blue: 34/255) : .white
    }

    private var shadowColor: Color {
        colorScheme == .dark ? .black : Color.black.opacity(0.6)
    }

    private var iconBaseColor: Color {
        option.iconColor ?? accentColor
    }

    private var iconBackgroundColor: Color {
        iconBaseColor.designLighten(by: colorScheme == .dark ? 0.2 : 0.6).opacity(colorScheme == .dark ? 0.35 : 0.25)
    }

    @ViewBuilder
    private var selectionIndicator: some View {
        if allowsMultipleSelection {
            checkmarkIndicator
        } else {
            radioIndicator
        }
    }

    private var radioIndicator: some View {
        let borderColor = Color(red: 203/255, green: 213/255, blue: 225/255)

        return ZStack {
            Circle()
                .fill(isSelected ? accentColor : Color.white)
                .frame(width: 26, height: 26)
                .shadow(color: accentColor.opacity(isSelected ? 0.4 : 0), radius: 10, x: 0, y: 4)

            Circle()
                .strokeBorder(isSelected ? accentColor : borderColor.opacity(colorScheme == .dark ? 0.6 : 1), lineWidth: 2)
                .frame(width: 26, height: 26)

            Circle()
                .fill(Color.white)
                .frame(width: 10, height: 10)
                .scaleEffect(isSelected ? 1 : 0.1)
                .opacity(isSelected ? 1 : 0)
                .animation(.easeOut(duration: 0.2), value: isSelected)
        }
    }

    private var checkmarkIndicator: some View {
        let borderColor = Color(red: 203/255, green: 213/255, blue: 225/255)

        return ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isSelected ? accentColor : Color.white)
                .frame(width: 26, height: 26)
                .shadow(color: accentColor.opacity(isSelected ? 0.35 : 0), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(isSelected ? accentColor : borderColor.opacity(colorScheme == .dark ? 0.6 : 1), lineWidth: 2)
                )

            Image(systemName: "checkmark")
                .font(typography.iconSmall)
                .foregroundColor(.white)
                .opacity(isSelected ? 1 : 0)
                .animation(.easeOut(duration: 0.2), value: isSelected)
        }
    }

    private func iconView(systemName: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(iconBackgroundColor)
                .frame(width: 48, height: 48)

            Image(systemName: systemName)
                .font(typography.iconLarge)
                .foregroundStyle(iconGradient)
        }
    }

    private var iconGradient: LinearGradient {
        let start = iconBaseColor.designLighten(by: 0.35)
        return LinearGradient(
            gradient: Gradient(colors: [start, iconBaseColor]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func selectedOverlay(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        accentColor.designLighten(by: 0.6).opacity(isSelected ? 0.12 : 0.03),
                        Color.clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}
