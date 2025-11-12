import SwiftUI
import DesignSystem

@available(iOS 17.0, macOS 11.0, *)
struct CompactTrustIndicator: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.designTypography) private var typography

    let icon: String
    let text: String

    private var textColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7)
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(typography.iconLarge)
                .foregroundColor(.green)

            Text(text)
                .font(typography.subtitle)
                .foregroundColor(textColor)
        }
    }
}
