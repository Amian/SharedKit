import SwiftUI
import DesignSystem

@available(iOS 15.0, macOS 12.0, *)
public struct OnboardingFlowView: View {
    let steps: [OnboardingStep]
    let onFinish: (_ responses: [OnboardingResponse]) -> Void
    let onStepChange: ((Int) -> Void)?

    @State private var currentIndex: Int = 0
    @State private var selections: [Int: Set<UUID>] = [:]

    public init(
        steps: [OnboardingStep],
        onFinish: @escaping (_ responses: [OnboardingResponse]) -> Void,
        onStepChange: ((Int) -> Void)? = nil
    ) {
        self.steps = steps
        self.onFinish = onFinish
        self.onStepChange = onStepChange
    }

    public var body: some View {
        let step = steps[currentIndex]

        VStack(spacing: 0) {
            if steps.count > 1 {
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
    }

    private func contentView(for step: OnboardingStep) -> some View {
        Group {
            switch step {
            case .info(let info):
                OnboardingInfoView(step: info) {
                    advance()
                }
            case .question(let question):
                OnboardingQuestionView(
                    step: question,
                    selections: binding(for: currentIndex),
                    onAdvance: advance
                )
            }
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
        Color(red: 203/255, green: 213/255, blue: 225/255)
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
}
