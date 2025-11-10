import SwiftUI

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
                    .padding(.horizontal, 32)
                    .padding(.top, 40)
                    .padding(.bottom, 28)
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
        HStack {
            ForEach(0..<steps.count, id: \.self) { index in
                Capsule()
                    .fill(index <= currentIndex ? Color.primary.opacity(0.8) : Color.primary.opacity(0.15))
                    .frame(height: 4)
            }
        }
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
}
