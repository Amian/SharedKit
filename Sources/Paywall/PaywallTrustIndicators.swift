import SwiftUI

struct CompactTrustIndicator: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.green)

            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
        }
    }
}
