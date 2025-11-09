import SwiftUI

public struct PaywallConfiguration: Hashable {
    public var revenueCatPublicKey: String
    public var offeringIdentifier: String?
    public var accentColor: Color
    public var features: [PaywallFeature]
    public var privacyPolicyURL: URL?
    public var termsOfServiceURL: URL?

    public init(
        revenueCatPublicKey: String,
        offeringIdentifier: String? = nil,
        accentColor: Color = Color.orange,
        features: [PaywallFeature] = .sampleFeatures(),
        privacyPolicyURL: URL? = nil,
        termsOfServiceURL: URL? = nil
    ) {
        self.revenueCatPublicKey = revenueCatPublicKey
        self.offeringIdentifier = offeringIdentifier
        self.accentColor = accentColor
        self.features = features
        self.privacyPolicyURL = privacyPolicyURL
        self.termsOfServiceURL = termsOfServiceURL
    }
}
