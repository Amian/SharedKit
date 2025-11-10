import SwiftUI

struct CompactTrustIndicator: View {
    @Environment(\.colorScheme) private var colorScheme

    let icon: String
    let text: String

    private var textColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7)
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.green)

            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(textColor)
        }
    }
}
