import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct OnboardingInfoView: View {
    let step: OnboardingInfoStep
    let action: () -> Void

    @Environment(\.colorScheme) private var systemScheme

    var body: some View {
        content
            .background(step.backgroundColor.ignoresSafeArea())
            .preferredColorScheme(step.appearance.preferredColorScheme)
    }

    private var content: some View {
        VStack(spacing: 24) {
            Spacer()

            if let imageName = step.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220, maxHeight: 220)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 8)
            }

            VStack(spacing: 8) {
                Text(step.title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(step.accentColor)

                if let subtitle = step.subtitle {
                    Text(subtitle)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(textColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }

            Spacer()

            Button(action: action) {
                Text(step.ctaTitle.uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(buttonTextColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(step.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 32)
        }
    }

    private var resolvedScheme: ColorScheme {
        step.appearance.preferredColorScheme ?? systemScheme
    }

    private var textColor: Color {
        resolvedScheme == .dark ? .white : .black
    }

    private var buttonTextColor: Color {
        resolvedScheme == .dark ? .black : .white
    }
}
