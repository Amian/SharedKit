import SwiftUI

public struct PaywallFeature: Identifiable, Hashable {
    public let id: UUID
    public var icon: String
    public var title: String
    public var subtitle: String
    public var color: Color
    public var delay: Double

    public init(
        id: UUID = UUID(),
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        delay: Double = 0.0
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.delay = delay
    }
}

public extension Array where Element == PaywallFeature {
    static func sampleFeatures(accentColor: Color = Color.orange) -> [PaywallFeature] {
        [
            PaywallFeature(
                icon: "infinity",
                title: "Unlimited Activities",
                subtitle: "Track every session without artificial caps or limits.",
                color: accentColor,
                delay: 0.2
            ),
            PaywallFeature(
                icon: "chart.bar.fill",
                title: "Advanced Analytics",
                subtitle: "Unlock deeper insights and trend lines for your progress.",
                color: accentColor.opacity(0.8),
                delay: 0.3
            ),
            PaywallFeature(
                icon: "sparkles",
                title: "Personalized Coaching",
                subtitle: "Adaptive recommendations tuned to your current goals.",
                color: .yellow.opacity(0.8),
                delay: 0.4
            ),
            PaywallFeature(
                icon: "lock.open.display",
                title: "Sync Everywhere",
                subtitle: "Access premium on iPhone, iPad, Watch, and Mac.",
                color: .green.opacity(0.8),
                delay: 0.5
            )
        ]
    }
}
