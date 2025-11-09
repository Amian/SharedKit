import SwiftUI

struct PremiumFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let delay: Double
}

enum PaywallFeatureCatalog {
    static let highlighted: [PremiumFeature] = [
        PremiumFeature(
            icon: "infinity",
            title: "Unlimited Activities",
            subtitle: "Track every session without artificial caps or limits.",
            color: .paywallAccent,
            delay: 0.2
        ),
        PremiumFeature(
            icon: "chart.bar.fill",
            title: "Advanced Analytics",
            subtitle: "Unlock deeper insights and trend lines for your progress.",
            color: .paywallAccent.opacity(0.8),
            delay: 0.3
        ),
        PremiumFeature(
            icon: "sparkles",
            title: "Personalized Coaching",
            subtitle: "Adaptive recommendations tuned to your current goals.",
            color: .yellow.opacity(0.8),
            delay: 0.4
        ),
        PremiumFeature(
            icon: "lock.open.display",
            title: "Sync Everywhere",
            subtitle: "Access premium on iPhone, iPad, Watch, and Mac.",
            color: .green.opacity(0.8),
            delay: 0.5
        )
    ]
}
