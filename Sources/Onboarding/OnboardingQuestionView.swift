import SwiftUI
import DesignSystem

@available(iOS 17.0, *)
struct OnboardingQuestionView: View {
    let step: OnboardingQuestionStep
    @Binding var selections: Set<UUID>
    let onAdvance: () -> Void

    @Environment(\.colorScheme) private var systemScheme
    @Environment(\.designTypography) private var typography

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        if let imageName = step.imageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 200, maxHeight: 200)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                        }

                        header
                        optionList
                    }
                    .frame(maxWidth: 440)
                    .padding(.horizontal, 18)
                    .padding(.top, 20)
                    .padding(.bottom, 6)
                    .frame(maxWidth: .infinity)
                }

                primaryButton
                    .frame(maxWidth: 440)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .padding(.bottom, 8)
            }
        }
        .preferredColorScheme(step.appearance.preferredColorScheme)
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

    private var canAdvance: Bool {
        selections.isEmpty == false
    }

    private func toggleSelection(for id: UUID) {
        if step.allowsMultipleSelection {
            if selections.contains(id) {
                selections.remove(id)
            } else {
                selections.insert(id)
            }
        } else {
            selections = [id]
        }
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

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(step.title)
                .font(typography.title)
                .foregroundColor(titleColor)
                .lineSpacing(4)

            if let subtitle = step.subtitle {
                Text(subtitle)
                    .font(typography.subtitle)
                    .foregroundColor(subtitleColor)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var optionList: some View {
        VStack(spacing: 10) {
            ForEach(step.options) { option in
                Button {
                    toggleSelection(for: option.id)
                } label: {
                    OnboardingOptionRow(
                        option: option,
                        isSelected: selections.contains(option.id),
                        accentColor: step.accentColor,
                        allowsMultipleSelection: step.allowsMultipleSelection
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var primaryButton: some View {
        Button(action: onAdvance) {
            Text(step.ctaTitle)
                .font(typography.button)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(accentGradient)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: step.accentColor.opacity(0.32), radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(!canAdvance)
        .opacity(canAdvance ? 1 : 0.4)
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
}
