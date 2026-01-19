import SwiftUI
import DesignSystem

@available(iOS 17.0, macOS 11.0, *)
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
        Group {
            if step.backgroundImageName != nil {
                VStack(spacing: 24) {
                    Spacer(minLength: 0)
                    contentStack
                    if step.accessoryPlacement == .afterContentBeforeCTA {
                        accessoryView
                    }
                    if step.showsCTA {
                        primaryButton
                            .padding(.bottom, 24)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            } else {
                VStack(spacing: 24) {
                    contentStack
                        .frame(maxHeight: .infinity)

                    if step.accessoryPlacement == .afterContentBeforeCTA {
                        accessoryView
                    }

                    if step.showsCTA {
                        primaryButton
                            .padding(.bottom, 24)
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
        .padding(.top, 12)
        .task(id: step) {
            guard let delay = step.autoAdvanceAfter else { return }
            let nanoseconds = UInt64(delay * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            await MainActor.run {
                action()
            }
        }
    }

    private var resolvedScheme: ColorScheme {
        step.appearance.preferredColorScheme ?? systemScheme
    }

    private var titleColor: Color {
        step.titleColor ?? (resolvedScheme == .dark
            ? Color.white
            : Color(red: 15/255, green: 23/255, blue: 42/255))
    }

    private var subtitleColor: Color {
        step.subtitleColor ?? (resolvedScheme == .dark
            ? Color.white.opacity(0.75)
            : Color(red: 71/255, green: 85/255, blue: 105/255))
    }

    private var primaryButton: some View {
        Button(action: action) {
            Text(step.ctaTitle)
                .font(typography.button)
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
        Group {
            if step.backgroundImageName != nil {
                Color.clear
            } else {
                step.backgroundColor
            }
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

    @ViewBuilder
    private var contentStack: some View {
        VStack(spacing: 16) {
            if step.accessoryPlacement == .aboveImage {
                accessoryView
            }

            switch step.imagePlacement {
            case .top:
                imageView
                textStack
            case .betweenTitleAndSubtitle:
                titleView
                imageView
                subtitleView
            case .bottom:
                textStack
                imageView
            }
        }
    }

    @ViewBuilder
    private var textStack: some View {
        VStack(spacing: 12) {
            titleView
            subtitleView
        }
    }

    @ViewBuilder
    private var titleView: some View {
        if step.title.isEmpty == false {
            Text(step.title)
                .font(typography.title)
                .foregroundColor(titleColor)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
        }
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let subtitle = step.subtitle {
            Text(subtitle)
                .font(typography.subtitle)
                .foregroundColor(subtitleColor)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 24)
        }
    }

    @ViewBuilder
    private var imageView: some View {
        if let videoName = step.videoName, let url = videoURL(for: videoName) {
            LoopingVideoView(url: url)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 12)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        } else if let gifName = step.gifName {
            AnimatedGIFView(resourceName: gifName)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 12)
        } else if let imageName = step.imageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 12)
        }
    }

    private func videoURL(for name: String) -> URL? {
        let nsName = name as NSString
        let ext = nsName.pathExtension
        let baseName = nsName.deletingPathExtension
        if ext.isEmpty {
            return Bundle.main.url(forResource: name, withExtension: nil)
        }
        return Bundle.main.url(forResource: baseName, withExtension: ext)
    }

    @ViewBuilder
    private var accessoryView: some View {
        if let accessory = step.accessory {
            accessory
        }
    }
}
