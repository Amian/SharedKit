import SwiftUI
import DesignSystem
#if os(iOS)
import StoreKit
import UIKit
#endif

@available(iOS 17.0, macOS 11.0, *)
struct OnboardingReviewView: View {
    let step: OnboardingReviewStep
    let onAdvance: () -> Void

    @Environment(\.designTypography) private var typography
    @State private var isRequestingReview = false

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
        Group {
            if step.backgroundImageName != nil {
                VStack(spacing: 24) {
                    Spacer(minLength: 0)
                    contentStack
                    primaryButton
                        .padding(.bottom, 24)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            } else {
                VStack(spacing: 24) {
                    contentStack
                        .frame(maxHeight: .infinity)
                    primaryButton
                        .padding(.bottom, 24)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding(.top, 12)
    }

    private var contentStack: some View {
        VStack(spacing: 16) {
            imageView

            VStack(spacing: 10) {
                Text(step.title)
                    .font(typography.title)
                    .multilineTextAlignment(.center)
                    .foregroundColor(titleColor)

                if let subtitle = step.subtitle {
                    Text(subtitle)
                        .font(typography.subtitle)
                        .foregroundColor(subtitleColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 12)
                }
            }
        }
    }

    private var primaryButton: some View {
        Button {
            guard isRequestingReview == false else { return }
            isRequestingReview = true
            requestReview()
            Task {
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                onAdvance()
            }
        } label: {
            Group {
                if isRequestingReview {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text(step.ctaTitle)
                        .font(typography.button)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: step.accentColor.opacity(0.28), radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(isRequestingReview)
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

    private var imageView: some View {
        Group {
            if let imageName = step.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
    }

    private var titleColor: Color {
        step.titleColor ?? (step.appearance.preferredColorScheme == .dark
            ? Color.white
            : Color(red: 15/255, green: 23/255, blue: 42/255))
    }

    private var subtitleColor: Color {
        step.subtitleColor ?? (step.appearance.preferredColorScheme == .dark
            ? Color.white.opacity(0.75)
            : Color(red: 71/255, green: 85/255, blue: 105/255))
    }

    private var backgroundView: some View {
        Group {
            if step.backgroundImageName != nil {
                Color.clear
            } else {
                step.backgroundColor
            }
        }
        .ignoresSafeArea()
    }

    private func requestReview() {
        #if os(iOS)
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            SKStoreReviewController.requestReview(in: scene)
        }
        #endif
    }
}
