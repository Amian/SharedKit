import Foundation
import SwiftData
import RevenueCat

@available(iOS 17.0, macOS 14.0, *)
@MainActor
public final class SubscriptionManager: NSObject, ObservableObject {
    public static let shared = SubscriptionManager()

    @Published public private(set) var isPremium: Bool = false

    private var isConfigured = false
    private let storageKey = "com.shareduikit.paywall.premiumUnlocked"

    private override init() {
        super.init()
    }

    /// Call as soon as your application launches to configure RevenueCat and hydrate any persisted state.
    public func configureIfPossible(modelContext: ModelContext? = nil) {
        guard !isConfigured else { return }

        guard !RevenueCatConfig.publicSDKKey.isEmpty else {
            refreshFromStorage(modelContext: modelContext)
            isConfigured = true
            return
        }

        Purchases.configure(withAPIKey: RevenueCatConfig.publicSDKKey)
        Purchases.shared.delegate = self

        Task { @MainActor in
            await loadCustomerInfo(modelContext: modelContext)
        }

        isConfigured = true
    }

    /// Reads the persisted premium state either from SwiftData or UserDefaults.
    public func refreshFromStorage(modelContext: ModelContext? = nil) {
        if let context = modelContext, let existing = fetchSettings(in: context) {
            isPremium = existing.premiumUnlocked
        } else {
            isPremium = UserDefaults.standard.bool(forKey: storageKey)
        }
    }

    /// Persists the premium flag to both SwiftData and UserDefaults for resiliency.
    public func persistPremium(_ enabled: Bool, modelContext: ModelContext? = nil) {
        if let context = modelContext {
            let settings: PaywallSettings
            if let existing = fetchSettings(in: context) {
                settings = existing
            } else {
                let created = PaywallSettings()
                context.insert(created)
                settings = created
            }

            settings.premiumUnlocked = enabled
            settings.lastUpdated = .now
            try? context.save()
        }

        UserDefaults.standard.set(enabled, forKey: storageKey)
        isPremium = enabled
    }

    private func fetchSettings(in context: ModelContext) -> PaywallSettings? {
        let descriptor = FetchDescriptor<PaywallSettings>(predicate: nil)
        return try? context.fetch(descriptor).first
    }

    private func loadCustomerInfo(modelContext: ModelContext?) async {
        do {
            let info = try await Purchases.shared.customerInfo()
            updatePremiumStatus(from: info, modelContext: modelContext)
        } catch {
            refreshFromStorage(modelContext: modelContext)
        }
    }

    private func updatePremiumStatus(from info: CustomerInfo?, modelContext: ModelContext?) {
        let hasActive = !(info?.entitlements.active.isEmpty ?? true)
        persistPremium(hasActive, modelContext: modelContext)
    }
}

@available(iOS 17.0, macOS 14.0, *)
extension SubscriptionManager: PurchasesDelegate {
    nonisolated public func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor [weak self] in
            self?.updatePremiumStatus(from: customerInfo, modelContext: nil)
        }
    }
}
