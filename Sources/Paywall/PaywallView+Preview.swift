import SwiftUI
import RevenueCat

#if DEBUG
@available(iOS 17.0, macOS 14.0, *)
#Preview("Paywall • Light") {
    PaywallPreview.makePreview()
}

@available(iOS 17.0, macOS 14.0, *)
#Preview("Paywall • Dark") {
    PaywallPreview.makePreview(preferredColorScheme: .dark)
}

@available(iOS 17.0, macOS 14.0, *)
@MainActor
private enum PaywallPreview {
    static let accentColor = Color.purple

    static var configuration: PaywallConfiguration {
        PaywallConfiguration(
            revenueCatPublicKey: "",
            accentColor: accentColor,
            features: [PaywallFeature].sampleFeatures(accentColor: accentColor),
            privacyPolicyURL: URL(string: "https://example.com/privacy"),
            termsOfServiceURL: URL(string: "https://example.com/terms"),
            appearance: .system,
            headline: "Upgrade to Nimbus Pro",
            subheadline: "Unlock unlimited habits, reminders, and smart insights."
        )
    }

    static func makePreview(preferredColorScheme: ColorScheme = .light) -> some View {
        PaywallView(configuration: configuration, previewOffering: offering)
            .preferredColorScheme(preferredColorScheme)
    }

    private static let offering: Offering = {
        Offering(
            identifier: "preview_offering",
            serverDescription: "Preview Offering",
            availablePackages: [
                package(
                    type: .weekly,
                    title: "Weekly",
                    price: 6.99,
                    priceString: "$6.99",
                    period: RevenueCat.SubscriptionPeriod(value: 1, unit: .week),
                    intro: introTrial(
                        value: 7,
                        unit: .day
                    )
                ),
                package(
                    type: .monthly,
                    title: "Monthly",
                    price: 12.99,
                    priceString: "$12.99",
                    period: RevenueCat.SubscriptionPeriod(value: 1, unit: .month)
                ),
                package(
                    type: .annual,
                    title: "Annual",
                    price: 59.99,
                    priceString: "$59.99",
                    period: RevenueCat.SubscriptionPeriod(value: 1, unit: .year)
                )
            ]
        )
    }()

    private static func package(
        type: RevenueCat.PackageType,
        title: String,
        price: Decimal,
        priceString: String,
        period: RevenueCat.SubscriptionPeriod?,
        intro: TestStoreProductDiscount? = nil
    ) -> Package {
        let testProduct = TestStoreProduct(
            localizedTitle: title,
            price: price,
            localizedPriceString: priceString,
            productIdentifier: "preview.\(type)",
            productType: .autoRenewableSubscription,
            localizedDescription: "\(title) access",
            subscriptionGroupIdentifier: "preview",
            subscriptionPeriod: period,
            introductoryDiscount: intro,
            locale: Locale(identifier: "en_US")
        )

        return Package(
            identifier: "preview.\(type)",
            packageType: type,
            storeProduct: testProduct.toStoreProduct(),
            offeringIdentifier: "preview_offering"
        )
    }

    private static func introTrial(
        value: Int,
        unit: RevenueCat.SubscriptionPeriod.Unit,
        priceString: String = "$0.00"
    ) -> TestStoreProductDiscount {
        TestStoreProductDiscount(
            identifier: "intro",
            price: 0,
            localizedPriceString: priceString,
            paymentMode: .freeTrial,
            subscriptionPeriod: .init(value: value, unit: unit),
            numberOfPeriods: 1,
            type: .introductory
        )
    }
}
#endif
