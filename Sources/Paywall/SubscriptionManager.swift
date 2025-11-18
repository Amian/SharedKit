import Foundation
import RevenueCat

@available(iOS 17.0, macOS 14.0, *)
@MainActor
public final class SubscriptionManager: NSObject, ObservableObject {
    public static let shared = SubscriptionManager()

    @Published public private(set) var isPremium: Bool = false

    public private(set) var configuration: PaywallConfiguration?

    private var isConfigured = false
    private let storageKey = "com.shareduikit.paywall.premiumUnlocked"

    private override init() {
        super.init()
    }

    /// Call as soon as your application launches to configure RevenueCat and hydrate any persisted state.
    public func configure(with configuration: PaywallConfiguration) {
        self.configuration = configuration

        guard !isConfigured else { return }

        guard !configuration.revenueCatPublicKey.isEmpty else {
            // Without a key we cannot validate entitlements; default to non-premium.
            persistPremium(false)
            isConfigured = true
            return
        }

        Purchases.configure(withAPIKey: configuration.revenueCatPublicKey)
        Purchases.shared.delegate = self

        Task { @MainActor [weak self] in
            await self?.loadCustomerInfo()
        }

        isConfigured = true
    }

    /// Persists the premium flag in UserDefaults.
    public func persistPremium(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: storageKey)
        isPremium = enabled
    }

    private func loadCustomerInfo() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            updatePremiumStatus(from: info)
        } catch {
            // If we cannot validate, default to non-premium to avoid granting access incorrectly.
            persistPremium(false)
        }
    }

    private func updatePremiumStatus(from info: CustomerInfo?) {
        let hasActive = !(info?.entitlements.active.isEmpty ?? true)
        persistPremium(hasActive)
    }
}

@available(iOS 17.0, macOS 14.0, *)
extension SubscriptionManager: PurchasesDelegate {
    nonisolated public func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor [weak self] in
            self?.updatePremiumStatus(from: customerInfo)
        }
    }
}
