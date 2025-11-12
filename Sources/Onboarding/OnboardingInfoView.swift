import SwiftUI
import DesignSystem

@available(iOS 17.0, *)
struct OnboardingInfoView: View {
    let step: OnboardingInfoStep
    let action: () -> Void

    @Environment(\.colorScheme) private var systemScheme
    @Environment(\.designTypography) private var typography

    var body: some View {
        ZStack {
            backgroundView

            content
                .frame(maxWidth: 480)
                .padding(.horizontal, 24)
        }
        .preferredColorScheme(step.appearance.preferredColorScheme)
    }

    private var content: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 12)

            if let imageName = step.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220, maxHeight: 220)
                    .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 12)
                    .padding(.bottom, 8)
            }

            VStack(spacing: 12) {
                Text(step.title)
                    .font(typography.title)
                    .foregroundColor(titleColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                if let subtitle = step.subtitle {
                    Text(subtitle)
                        .font(typography.subtitle)
                        .foregroundColor(subtitleColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                }
            }

            Spacer()

            primaryButton
                .padding(.bottom, 24)
        }
    }

    private var resolvedScheme: ColorScheme {
        step.appearance.preferredColorScheme ?? systemScheme
    }

    private var titleColor: Color {
        resolvedScheme == .dark ? Color.white : Color(red: 15/255, green: 23/255, blue: 42/255)
    }

    private var subtitleColor: Color {
        resolvedScheme == .dark ? Color.white.opacity(0.75) : Color(red: 71/255, green: 85/255, blue: 105/255)
    }

    private var primaryButton: some View {
        Button(action: action) {
            Text(step.ctaTitle)
                .font(typography.cta)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: step.accentColor.opacity(0.3), radius: 18, x: 0, y: 10)
                .padding(.horizontal, 4)
        }
        .buttonStyle(.plain)
    }

    private var accentGradient: LinearGradient {
        let start = step.accentColor.designLighten(by: 0.12)
        let end = step.accentColor.designDarken(by: 0.05)
        return LinearGradient(
            gradient: Gradient(colors: [start, end]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: resolvedScheme == .dark ? darkBackgroundColors : lightBackgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            step.backgroundColor.opacity(0.15)
        }
        .ignoresSafeArea()
    }

    private var lightBackgroundColors: [Color] {
        [
            Color(red: 248/255, green: 250/255, blue: 252/255),
            Color(red: 226/255, green: 232/255, blue: 240/255)
        ]
    }

    private var darkBackgroundColors: [Color] {
        [
            Color(red: 15/255, green: 19/255, blue: 32/255),
            Color(red: 10/255, green: 12/255, blue: 20/255)
        ]
    }
}
