# SharedUIKit Paywall

`SharedUIKit` is a Swift Package that currently exposes three modules:

- `FirebaseKit`: thin wrapper around Firebase (Core, Analytics, Crashlytics, RemoteConfig) with a single configure entry point and protocol-based clients.
- `Paywall`: RevenueCat-driven subscription paywall plus entitlement manager.
- `Onboarding`: simple, configurable welcome screen you can reuse across apps.

## 1. Add the Package

1. **Xcode** → **Package Dependencies** → **Add Package Dependency…**
2. Enter the repo URL (e.g. `https://github.com/<you>/SharedUIKit.git`)
3. When prompted for products, select **Paywall** and/or **Onboarding** depending on what you need.

`Package.swift` excerpt if you prefer manual editing:

```swift
dependencies: [
    .package(url: "https://github.com/<you>/SharedUIKit.git", branch: "main")
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "FirebaseKit", package: "SharedUIKit"),
            .product(name: "Paywall", package: "SharedUIKit"),
            .product(name: "Onboarding", package: "SharedUIKit")
        ]
    )
]
```

## FirebaseKit Setup

- Keep `GoogleService-Info.plist`, the Crashlytics run script, and any per-app Firebase config in each host app target.
- Firebase is not auto-configured; call `FirebaseKit.configure()` once during app launch before using any clients.

```swift
import FirebaseKit

@main
struct MyApp: App {
    init() {
        FirebaseKit.configure()
    }

    var body: some Scene { ... }
}
```

Default clients are provided:

```swift
FirebaseKit.analytics.logEvent("opened_paywall", parameters: ["source": "home"])
FirebaseKit.crashReporter.log("Reached paywall screen")
FirebaseKit.remoteConfig.fetchAndActivate { result in
    // use FirebaseKit.remoteConfig.bool(forKey: "newPaywallEnabled")
}
```

If you prefer dependency injection, depend on the protocols `AnalyticsClient`, `CrashReporter`, and `RemoteConfigClient` and pass in the Firebase-backed instances above.

## 2. Create a Configuration

Define a `PaywallConfiguration` in your app (typically once at launch) so each host can supply its own RevenueCat key, accent color, feature list, and legal links.

```swift
import Paywall

let paywallConfig = PaywallConfiguration(
    revenueCatPublicKey: "<your-public-key>",
    offeringIdentifier: "default", // optional
    accentColor: .orange,
    features: [
        PaywallFeature(icon: "sparkles", title: "Magic Feature", subtitle: "Describe the benefit", color: .pink),
        PaywallFeature(icon: "bolt.fill", title: "Faster Sync", subtitle: "Real-time updates everywhere", color: .yellow),
        PaywallFeature(icon: "checkmark.seal", title: "No Ads") // subtitle optional
    ],
    privacyPolicyURL: URL(string: "https://example.com/privacy"),
    termsOfServiceURL: URL(string: "https://example.com/terms"),
    appearance: .system, // or .light / .dark to force a theme
    headline: "Unlock Everything",
    subheadline: "Pick the plan that’s right for you"
)
```

> ⚠️ Leaving `revenueCatPublicKey` empty means the paywall won’t load products; use that only for UI previews.

## 3. Initialize Paywall Once

Call `Paywall.configure(with:)` early in app launch (e.g. your `App` initializer or `application(_:didFinishLaunchingWithOptions:)`).  
This stores the configuration, boots `SubscriptionManager`, and makes the data available across the module.

```swift
@main
struct MyApp: App {
    init() {
        Paywall.configure(with: paywallConfig)
    }

    var body: some Scene { ... }
}
```

## 4. Present the Paywall

`PaywallView` is a SwiftUI view available on iOS 17/macOS 14 and later. Present it modally whenever you need to upsell:

```swift
import SwiftUI
import Paywall

struct ContentView: View {
    @State private var showPaywall = false

    var body: some View {
        Button("Unlock Premium") {
            showPaywall = true
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView() // uses the configuration from Paywall.configure(with:)
        }
    }
}
```

`PaywallView` automatically:

- Loads the configured offering
- Displays plans/features
- Calls `Purchases.shared.purchase`
- Persists last-known premium status using `SubscriptionManager`

## 5. Gate Premium Features

Observe `SubscriptionManager.shared.$isPremium` (or `Paywall.subscriptionManager.$isPremium`) to enable or disable premium-only functionality:

```swift
@StateObject private var subscriptionManager = Paywall.subscriptionManager

var body: some View {
    if subscriptionManager.isPremium {
        PremiumDashboard()
    } else {
        FreeTierView()
    }
}

// Or outside of SwiftUI:
if Paywall.isPremium {
    // unlock feature
}
```

Treat `isPremium` as cached state: the definitive source of truth is still RevenueCat’s entitlements, which the manager pulls every time `Paywall.configure(with:)` runs (and whenever purchases complete).

## 6. Customization Hooks

- **Branding:** Supply your accent color, features, and preferred appearance via `PaywallConfiguration`. For deeper changes, fork the components (`PaywallFeatureComponents`, `PaywallPackageCards`) and drop them back in.
- **Legal Links:** Pass `privacyPolicyURL` / `termsOfServiceURL` in the configuration; the buttons are hidden automatically if you omit them.
- **Products:** Use the RevenueCat dashboard to configure offerings. Provide the specific `offeringIdentifier` in the configuration or let the paywall fall back to the current offering.

## 7. Common Questions

| Question | Answer |
| --- | --- |
| *Can users hack `UserDefaults` to unlock premium?* | The cache is only a UX convenience. The manager refreshes entitlements from RevenueCat each time it configures, so always check `SubscriptionManager` after RevenueCat sync completes. |
| *How do I share state across multiple bundle IDs?* | By default each app keeps its own cache. If you need shared state (e.g. App Group), modify `SubscriptionManager` to use `UserDefaults(suiteName:)` and coordinate RevenueCat entitlements accordingly. |
| *Need offline access?* | RevenueCat caches receipts, but you should decide how long to trust cached entitlements. Consider a server-to-server validation loop for stricter enforcement. |

## 8. Development Tips

- Run `swift build` (or open the package in Xcode) after updating the dependency to ensure RevenueCat resolves.
- To test purchases without affecting production:
  - Use RevenueCat sandbox / StoreKit testing.
  - Replace the public key with your sandbox key.
- Disable the paywall by guarding presentation with `#if DEBUG` when you need to iterate without hitting RevenueCat.

## 9. Extending the Library

The structure is intentionally simple: add new shared UI modules as separate targets under `Sources/<ModuleName>` and declare them in `Package.swift`. Each target can expose its own views/managers while sharing common dependencies.

---

Need help or want to add another UI surface (onboarding, settings, etc.)? Follow the same pattern: new target, dedicated files, and opt-in product in `Package.swift`.

---

## Onboarding Module

`Onboarding` now supports multi-step flows composed of two step types:

- `.info`: hero/welcome/validation screens (image + headline + CTA).
- `.question`: multiple-choice prompts where users select one or more answers.

### Configure steps

```swift
import Onboarding

let steps: [OnboardingStep] = [
    .info(
        OnboardingInfoStep(
            imageName: "Mascot",
            title: "duolingo",
            subtitle: "Learn for free. Forever.",
            ctaTitle: "Get Started",
            accentColor: .green,
            backgroundColor: Color(red: 0.06, green: 0.08, blue: 0.12),
            appearance: .dark
        )
    ),
    .question(
        OnboardingQuestionStep(
            title: "Which language are you learning?",
            subtitle: "Pick as many as you like.",
            allowsMultipleSelection: true,
            options: [
                OnboardingOption(title: "Spanish", iconName: "flag.fill"),
                OnboardingOption(title: "French", iconName: "flag.fill"),
                OnboardingOption(title: "Japanese", iconName: "flag.fill")
            ],
            ctaTitle: "Continue",
            accentColor: .green,
            backgroundColor: Color(UIColor.systemBackground)
        )
    ),
    .info(
        OnboardingInfoStep(
            title: "You're all set!",
            subtitle: "Let's personalize your experience.",
            ctaTitle: "Finish"
        )
    )
]
```

### Present the flow

```swift
struct OnboardingContainer: View {
    @State private var answers: [OnboardingResponse] = []
    @State private var completed = false

    var body: some View {
        if completed {
            MainAppView()
        } else {
            OnboardingFlowView(steps: steps) { responses in
                answers = responses
                completed = true
            }
        }
    }
}
```

The `OnboardingFlowView` handles navigation, option selection, and progress. The completion closure gives you every step plus the selected option IDs (if applicable) so you can store analytics or personalize subsequent UI.
