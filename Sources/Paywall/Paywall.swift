import Foundation

@available(iOS 17.0, macOS 14.0, *)
@MainActor
public enum Paywall {
    private static var sharedConfiguration: PaywallConfiguration?

    /// Stores the configuration and boots subscription services. Call once at launch.
    public static func configure(with configuration: PaywallConfiguration) {
        sharedConfiguration = configuration
        SubscriptionManager.shared.configure(with: configuration)
    }

    /// Returns the configuration that was most recently passed to ``configure(with:)``.
    public static var configuration: PaywallConfiguration? {
        sharedConfiguration
    }

    /// Convenience accessor so apps can gate UI without reaching for the manager directly.
    public static var isPremium: Bool {
        SubscriptionManager.shared.isPremium
    }

    /// Exposes the underlying manager for advanced use cases (observing publishers, refresh, etc.)
    public static var subscriptionManager: SubscriptionManager {
        SubscriptionManager.shared
    }
}
