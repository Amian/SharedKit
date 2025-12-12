import SwiftUI

import SwiftUI

public struct PaywallConfiguration: Hashable {
    public enum AppearancePreference: Hashable {
        case system
        case light
        case dark

        var preferredColorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }

    public var revenueCatPublicKey: String
    public var offeringIdentifier: String?
    public var accentColor: Color
    public var features: [PaywallFeature]
    public var privacyPolicyURL: URL?
    public var termsOfServiceURL: URL?
    public var appearance: AppearancePreference
    public var headline: String
    public var subheadline: String
    public var heroGIFName: String?

    public init(
        revenueCatPublicKey: String,
        offeringIdentifier: String? = nil,
        accentColor: Color = Color.orange,
        features: [PaywallFeature] = .sampleFeatures(),
        privacyPolicyURL: URL? = nil,
        termsOfServiceURL: URL? = nil,
        appearance: AppearancePreference = .system,
        headline: String = "Unlock Premium",
        subheadline: String = "Unlock your full potential with complete access",
        heroGIFName: String? = nil
    ) {
        self.revenueCatPublicKey = revenueCatPublicKey
        self.offeringIdentifier = offeringIdentifier
        self.accentColor = accentColor
        self.features = features
        self.privacyPolicyURL = privacyPolicyURL
        self.termsOfServiceURL = termsOfServiceURL
        self.appearance = appearance
        self.headline = headline
        self.subheadline = subheadline
        self.heroGIFName = heroGIFName
    }
}
