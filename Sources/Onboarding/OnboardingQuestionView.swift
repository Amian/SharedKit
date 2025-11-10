import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct OnboardingQuestionView: View {
    let step: OnboardingQuestionStep
    @Binding var selections: Set<UUID>
    let onAdvance: () -> Void

    @Environment(\.colorScheme) private var systemScheme

    var body: some View {
        VStack(spacing: 24) {
            ScrollView {
                VStack(spacing: 16) {
                    if let imageName = step.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 180, maxHeight: 180)
                            .padding(.top, 24)
                    }

                    Text(step.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(step.accentColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    if let subtitle = step.subtitle {
                        Text(subtitle)
                            .font(.system(size: 16))
                            .foregroundColor(textColor.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    VStack(spacing: 12) {
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
                    .padding(.horizontal, 24)
                }
            }

            Button(action: onAdvance) {
                Text(step.ctaTitle.uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(buttonTextColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(step.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 24)
            .disabled(!canAdvance)
            .opacity(canAdvance ? 1 : 0.4)
        }
        .background(step.backgroundColor.ignoresSafeArea())
        .preferredColorScheme(step.appearance.preferredColorScheme)
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
}
