import SwiftUI
import DesignSystem

@available(iOS 17.0, macOS 11.0, *)
public struct OnboardingFlowView: View {
    @Environment(\.colorScheme) private var systemScheme
    let steps: [OnboardingStep]
    let onFinish: (_ responses: [OnboardingResponse]) -> Void
    let onStepChange: ((Int) -> Void)?
    let configuration: OnboardingFlowConfiguration
    let onInfoStepPrimaryAction: ((OnboardingInfoStep, @escaping () -> Void) -> Void)?

    @State private var currentIndex: Int = 0
    @State private var selections: [Int: Set<UUID>] = [:]

    public init(
        steps: [OnboardingStep],
        reviewStep: OnboardingReviewStep? = nil,
        reviewInsertionIndex: Int? = nil,
        onFinish: @escaping (_ responses: [OnboardingResponse]) -> Void,
        onStepChange: ((Int) -> Void)? = nil,
        configuration: OnboardingFlowConfiguration = OnboardingFlowConfiguration(),
        onInfoStepPrimaryAction: ((OnboardingInfoStep, @escaping () -> Void) -> Void)? = nil
    ) {
        self.steps = Self.insert(reviewStep, into: steps, at: reviewInsertionIndex)
        self.onFinish = onFinish
        self.onStepChange = onStepChange
        self.configuration = configuration
        self.onInfoStepPrimaryAction = onInfoStepPrimaryAction
    }

    public init(
        steps: [OnboardingStep],
        onFinish: @escaping (_ responses: [OnboardingResponse]) -> Void,
        onStepChange: ((Int) -> Void)? = nil,
        configuration: OnboardingFlowConfiguration = OnboardingFlowConfiguration(),
        onInfoStepPrimaryAction: ((OnboardingInfoStep, @escaping () -> Void) -> Void)? = nil
    ) {
        self.init(
            steps: steps,
            reviewStep: nil,
            reviewInsertionIndex: nil,
            onFinish: onFinish,
            onStepChange: onStepChange,
            configuration: configuration,
            onInfoStepPrimaryAction: onInfoStepPrimaryAction
        )
    }

    public var body: some View {
        let step = steps[currentIndex]

        VStack(spacing: 0) {
            if configuration.showsBreadcrumbs && steps.count > 1 {
                progressOverlay
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 12)
            } else {
                Spacer(minLength: 32)
            }

            contentView(for: step)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .animation(.easeInOut, value: currentIndex)
        .preferredColorScheme(resolvedColorScheme(for: step))
        .background(backgroundView(for: step).ignoresSafeArea())
    }

    private func contentView(for step: OnboardingStep) -> some View {
        Group {
            switch step {
            case .info(let info):
                OnboardingInfoView(
                    step: info,
                    onPrimaryAction: { stopLoading in
                        if let onInfoStepPrimaryAction {
                            onInfoStepPrimaryAction(info) {
                                stopLoading()
                                advance()
                            }
                        } else {
                            stopLoading()
                            advance()
                        }
                    },
                    onAutoAdvance: {
                        advance()
                    }
                )
            case .question(let question):
                OnboardingQuestionView(
                    step: question,
                    selections: binding(for: currentIndex),
                    onAdvance: advance
                )
            case .review(let review):
                OnboardingReviewView(step: review) {
                    advance()
                }
            }
        }
    }

    private func backgroundColor(for step: OnboardingStep) -> Color {
        switch step {
        case .info(let info):
            return info.backgroundColor
        case .question(let question):
            return question.backgroundColor
        case .review(let review):
            return review.backgroundColor
        }
    }

    private func backgroundImageName(for step: OnboardingStep) -> String? {
        switch step {
        case .info(let info):
            return info.backgroundImageName
        case .question(let question):
            return question.backgroundImageName
        case .review(let review):
            return review.backgroundImageName
        }
    }

    @ViewBuilder
    private func backgroundView(for step: OnboardingStep) -> some View {
        if let imageName = backgroundImageName(for: step) {
            ZStack {
                backgroundColor(for: step)
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            }
        } else {
            backgroundColor(for: step)
        }
    }

    private var progressOverlay: some View {
        HStack(spacing: 8) {
            ForEach(0..<steps.count, id: \.self) { index in
                progressStep(isActive: index <= currentIndex)
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.25), value: currentIndex)
            }
        }
    }

    private var progressInactiveColor: Color {
        resolvedColorScheme(for: steps[currentIndex]) == .dark
            ? Color.white.opacity(0.35)
            : Color(red: 203/255, green: 213/255, blue: 225/255)
    }

    private var progressActiveGradient: LinearGradient {
        let accent = accentColor(for: steps[currentIndex])
        let start = accent.designLighten(by: 0.15)
        let end = accent.designDarken(by: 0.05)
        return LinearGradient(
            gradient: Gradient(colors: [start, end]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func advance() {
        if currentIndex + 1 < steps.count {
            currentIndex += 1
            onStepChange?(currentIndex)
        } else {
            finishFlow()
        }
    }

    private func finishFlow() {
        var responses: [OnboardingResponse] = []
        for (idx, step) in steps.enumerated() {
            switch step {
            case .info:
                responses.append(OnboardingResponse(stepIndex: idx, step: step, selectedOptionIDs: nil))
            case .question:
                let selected = selections[idx] ?? []
                responses.append(OnboardingResponse(stepIndex: idx, step: step, selectedOptionIDs: Array(selected)))
            case .review:
                responses.append(OnboardingResponse(stepIndex: idx, step: step, selectedOptionIDs: nil))
            }
        }
        onFinish(responses)
    }

    private func binding(for index: Int) -> Binding<Set<UUID>> {
        Binding {
            selections[index] ?? []
        } set: { newValue in
            selections[index] = newValue
        }
    }

    private func accentColor(for step: OnboardingStep) -> Color {
        switch step {
        case .info(let info):
            return info.accentColor
        case .question(let question):
            return question.accentColor
        case .review(let review):
            return review.accentColor
        }
    }

    @ViewBuilder
    private func progressStep(isActive: Bool) -> some View {
        if isActive {
            Capsule().fill(progressActiveGradient)
        } else {
            Capsule().fill(progressInactiveColor)
        }
    }

    private func resolvedColorScheme(for step: OnboardingStep) -> ColorScheme {
        switch step {
        case .info(let info):
            return info.appearance.preferredColorScheme ?? systemScheme
        case .question(let question):
            return question.appearance.preferredColorScheme ?? systemScheme
        case .review(let review):
            return review.appearance.preferredColorScheme ?? systemScheme
        }
    }

    private static func insert(
        _ reviewStep: OnboardingReviewStep?,
        into steps: [OnboardingStep],
        at index: Int?
    ) -> [OnboardingStep] {
        guard let reviewStep else { return steps }
        let clampedIndex: Int
        if let index {
            clampedIndex = max(0, min(index, steps.count))
        } else {
            clampedIndex = steps.count
        }
        var updated = steps
        updated.insert(.review(reviewStep), at: clampedIndex)
        return updated
    }
}
