import SwiftUI

@available(iOS 17.0, macOS 11.0, *)
public struct LinearProgressHeader: View {
    private let leadingText: String
    private let progress: Double
    private let accentGradient: LinearGradient
    private let percentColor: Color
    private let formatter: NumberFormatter

    public init(
        leadingText: String,
        progress: Double,
        accentColors: [Color] = [Color.purple, Color.blue],
        percentColor: Color = Color.purple
    ) {
        self.leadingText = leadingText
        self.progress = min(max(progress, 0), 1)
        self.accentGradient = LinearGradient(
            gradient: Gradient(colors: accentColors),
            startPoint: .leading,
            endPoint: .trailing
        )
        self.percentColor = percentColor

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 0
        self.formatter = numberFormatter
    }

    public var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(leadingText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.primary.opacity(0.8))

                Spacer()

                Text(percentText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(percentColor)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 8)

                    Capsule()
                        .fill(accentGradient)
                        .frame(width: max(8, geometry.size.width * progress), height: 8)
                        .animation(.easeInOut(duration: 0.25), value: progress)
                }
            }
            .frame(height: 10)
        }
        .padding(.horizontal, 4)
    }

    private var percentText: String {
        formatter.string(from: NSNumber(value: progress)) ?? "\(Int(progress * 100))%"
    }
}
