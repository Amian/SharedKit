import Foundation

/// Central place to configure RevenueCat credentials used by the Paywall target.
@MainActor
public enum RevenueCatConfig {
    /// Public SDK key issued by RevenueCat. Set to your production key before shipping.
    public static var publicSDKKey: String = "appl_GgIhaHzSTbnVsjVKqZgZMvsXXHO"

    /// Offering identifier configured in the RevenueCat dashboard.
    public static var offeringIdentifier: String = "default"

    /// Paywall template identifier if you leverage RevenueCatUI templates.
    public static var paywallName: String = "default"
}
