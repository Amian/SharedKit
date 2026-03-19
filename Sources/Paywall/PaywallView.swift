import SwiftUI
import RevenueCat
import DesignSystem
import UserNotifications

@available(iOS 17.0, macOS 11.0, *)
public struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.designTypography) private var typography

    private let configuration: PaywallConfiguration
    private let shouldLoadOfferingFromNetwork: Bool

    @State private var alertMessage: String?
    @State private var isLoading = true
    @State private var selectedPackage: Package?
    @State private var offering: Offering?
    @State private var isPurchasing = false
    @State private var showFeatures = false
    @State private var remindBeforeTrialEnds = false
    @State private var showCloseButton = false
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    public init(configuration: PaywallConfiguration? = nil, previewOffering: Offering? = nil) {
        let resolvedConfiguration: PaywallConfiguration

        if let configuration {
            resolvedConfiguration = configuration
            SubscriptionManager.shared.configure(with: configuration)
        } else if let shared = Paywall.configuration {
            resolvedConfiguration = shared
        } else {
            fatalError("PaywallView requires a configuration. Call Paywall.configure(with:) during app launch or pass one to PaywallView(configuration:).")
        }

        self.configuration = resolvedConfiguration
        let shouldLoad = previewOffering == nil && !resolvedConfiguration.revenueCatPublicKey.isEmpty
        self.shouldLoadOfferingFromNetwork = shouldLoad

        let initialSelection = PaywallView.initialSelection(from: previewOffering)
        self._offering = State(initialValue: previewOffering)
        self._selectedPackage = State(initialValue: initialSelection)
        self._remindBeforeTrialEnds = State(initialValue: false)
        self._isLoading = State(initialValue: shouldLoad)
    }

    private var accentColor: Color { configuration.accentColor }
    private var resolvedColorScheme: ColorScheme {
        configuration.appearance.preferredColorScheme ?? systemColorScheme
    }
    private var primaryTextColor: Color { resolvedColorScheme == .dark ? .white : .black }
    private var secondaryTextColor: Color {
        resolvedColorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7)
    }
    private var mutedTextColor: Color {
        resolvedColorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6)
    }
    private var backgroundColor: Color { Color.designSystemBackground }
    private var surfaceColor: Color {
        resolvedColorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05)
    }
    private var surfaceBorderColor: Color {
        resolvedColorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.1)
    }
    private var chipBackgroundColor: Color {
        resolvedColorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05)
    }
    private var shouldUseEdgeToEdgeHero: Bool {
        configuration.heroImageStyle == .edgeToEdge && configuration.heroImageName != nil
    }
    private var hasHeroVisual: Bool {
        configuration.heroImageName != nil || configuration.heroGIFName != nil
    }
    private var localizationBundle: Bundle {
        guard let code = configuration.localizationCode,
              let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }
    private var localizer: PaywallLocalization {
        PaywallLocalization(bundle: localizationBundle, table: configuration.localizationTable)
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                ScrollView {
                    adaptivePaywallContent(geometry: geometry)
                        .frame(minHeight: geometry.size.height)
                }
                .scrollIndicators(.hidden)
            }
        }
        .environment(\.paywallLocalization, localizer)
        .task {
            guard shouldLoadOfferingFromNetwork else { return }
            await loadOffering()
        }
        .onAppear(perform: startAnimations)
        .onReceive(subscriptionManager.$isPremium, perform: handlePremiumChange(_:))
        .alert(localized("paywall.alert.title", defaultValue: "Message"), isPresented: .constant(alertMessage != nil)) {
            Button(localized("paywall.alert.ok", defaultValue: "OK")) { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
        .preferredColorScheme(configuration.appearance.preferredColorScheme)
    }

    @MainActor
    private func startAnimations() {
        withAnimation {
            showFeatures = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            withAnimation(.easeOut(duration: 0.4)) {
                showCloseButton = true
            }
        }
    }

    @MainActor
    private func handlePremiumChange(_ isPremium: Bool) {
        if isPremium {
            dismiss()
        }
    }

    @ViewBuilder
    private func adaptivePaywallContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height < 700 ? 16 : 20) {
            headerSection(geometry: geometry)
            featureSection(for: geometry)
            pricingSection(for: geometry)
            callToActionButton(for: geometry)
            trustSection(using: geometry)
        }
        .padding(.bottom, 20)
    }
    
    private func headerSection(geometry: GeometryProxy) -> some View {
        let titleSpacing = geometry.size.height < 700 ? 12.0 : 18.0

        return VStack(spacing: geometry.size.height < 700 ? 8 : 12) {
            heroHeaderRow(geometry: geometry)
                .padding(.bottom, hasHeroVisual ? titleSpacing : 0)

            VStack(spacing: 4) {
                Text(configuration.headline)
                    .font(geometry.size.height < 700 ? typography.title : typography.displayLarge)
                    .foregroundColor(primaryTextColor)
                    .multilineTextAlignment(.center)

                Text(configuration.subheadline)
                    .font(typography.subtitle)
                    .foregroundColor(secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .lineLimit(nil)
            }
        }
    }

    @ViewBuilder
    private func heroHeaderRow(geometry: GeometryProxy) -> some View {
        if shouldUseEdgeToEdgeHero {
            edgeToEdgeHero(for: geometry)
        } else {
            standardHeroRow(for: geometry)
        }
    }

    private func standardHeroRow(for geometry: GeometryProxy) -> some View {
        HStack(alignment: .top) {
            Color.clear
                .frame(width: 32, height: 32)
            Spacer()
            heroVisual(for: geometry.size.height)
            Spacer()
            closeButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .opacity(showCloseButton ? 1 : 0)
    }

    @ViewBuilder
    private func edgeToEdgeHero(for geometry: GeometryProxy) -> some View {
        if let imageName = configuration.heroImageName {
            ZStack(alignment: .topTrailing) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: backgroundColor, location: 0.0),
                                .init(color: backgroundColor.opacity(0), location: 0.3),
                                .init(color: backgroundColor.opacity(0), location: 0.0),
                                .init(color: backgroundColor.opacity(0), location: 0.0)
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )

                closeButton
                    .padding(.top, max(8, geometry.safeAreaInsets.top + 8))
                    .padding(.trailing, 20)
                    .opacity(showCloseButton ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, -geometry.safeAreaInsets.top)
            .ignoresSafeArea(edges: [.top, .horizontal])
        } else {
            standardHeroRow(for: geometry)
        }
    }

    private var closeButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .black))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color.black, in: Circle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func heroVisual(for availableHeight: CGFloat) -> some View {
        let size: CGFloat = availableHeight < 700 ? 90 : 110

        if let imageName = configuration.heroImageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
        } else if let gifName = configuration.heroGIFName {
            AnimatedGIFView(resourceName: gifName)
                .frame(width: size, height: size)
//                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 28, style: .continuous)
//                        .stroke(accentColor.opacity(0.25), lineWidth: 1)
//                )
//                .shadow(color: accentColor.opacity(0.2), radius: 20, x: 0, y: 12)
        } else {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [accentColor.opacity(0.3), accentColor.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)

                Image(systemName: "crown.fill")
                    .font(.system(size: availableHeight < 700 ? 32 : 40, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [accentColor.opacity(0.7), accentColor]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(showFeatures ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: showFeatures)
            }
        }
    }

    @ViewBuilder
    private func featureSection(for geometry: GeometryProxy) -> some View {
        let features = configuration.features

        if features.isEmpty {
            EmptyView()
        } else {
            VStack(spacing: 8) {
                ForEach(Array(features.enumerated()), id: \.element.id) { entry in
                    CompactFeatureRow(feature: entry.element)
                        .opacity(showFeatures ? 1 : 0)
                        .offset(x: showFeatures ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(Double(entry.offset) * 0.1), value: showFeatures)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    private func pricingSection(for geometry: GeometryProxy) -> some View {
        VStack(spacing: 12) {
            Text(localized("paywall.choose_plan", defaultValue: "Choose Your Plan"))
                .font(typography.headingLarge)
                .foregroundColor(primaryTextColor)
                .opacity(showFeatures ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.8), value: showFeatures)

            if isLoading {
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                    Text(localized("paywall.loading_options", defaultValue: "Loading options…"))
                        .font(typography.subtitle)
                        .foregroundColor(secondaryTextColor)
                }
                .padding(.vertical, 16)
            } else if let offering {
                VStack(spacing: 8) {
                let packages = offering.availablePackages.sorted(by: { $0.packageType.rawValue > $1.packageType.rawValue })
                ForEach(packages, id: \.identifier) { package in
                    UltraCompactPackageCard(
                            package: package,
                            availablePackages: packages,
                            isSelected: selectedPackage?.identifier == package.identifier,
                            onSelect: { selectedPackage = package },
                            isSmallScreen: geometry.size.height < 700,
                            showFreeTrial: package.storeProduct.introductoryDiscount != nil,
                            accentColor: accentColor
                        )
                        .opacity(showFeatures ? 1 : 0)
                        .offset(y: showFeatures ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(1.0), value: showFeatures)
                    }
                }
            } else {
                Text(localized("paywall.no_packages", defaultValue: "No packages available right now. Please try again later."))
                    .font(typography.subtitle)
                    .foregroundColor(secondaryTextColor)
                    .padding(.vertical, 12)
            }
        }
        .padding(.horizontal, 20)
    }

    private func callToActionButton(for geometry: GeometryProxy) -> some View {
        Button(action: purchaseSelectedPackage) {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }

                Text(isPurchasing ? localized("paywall.processing", defaultValue: "Processing...") : ctaButtonText)
                    .font(typography.button)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height < 700 ? 44 : 48)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        selectedPackage != nil ? accentColor : Color.gray,
                        selectedPackage != nil ? accentColor.opacity(0.8) : Color.gray.opacity(0.8)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: geometry.size.height < 700 ? 22 : 24))
            .overlay(
                RoundedRectangle(cornerRadius: geometry.size.height < 700 ? 22 : 24)
                    .stroke(surfaceBorderColor, lineWidth: 1)
            )
            .shadow(color: (selectedPackage != nil ? accentColor : Color.gray).opacity(0.3), radius: 12, x: 0, y: 6)
            .scaleEffect(isPurchasing ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPurchasing)
        }
        .disabled(isPurchasing || selectedPackage == nil)
        .padding(.horizontal, 20)
        .opacity(showFeatures ? 1 : 0)
        .animation(.easeOut(duration: 0.6).delay(1.2), value: showFeatures)
    }

    private func trustSection(using geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height < 700 ? 8 : 12) {
            HStack(spacing: geometry.size.height < 700 ? 16 : 20) {
                CompactTrustIndicator(icon: "lock.shield.fill", text: localized("paywall.trust.secure", defaultValue: "Secure"))
                CompactTrustIndicator(icon: "arrow.clockwise", text: localized("paywall.trust.cancel_anytime", defaultValue: "Cancel Anytime"))
                CompactTrustIndicator(icon: "checkmark.seal.fill", text: localized("paywall.trust.no_hidden_fees", defaultValue: "No Hidden Fees"))
            }
            .opacity(showFeatures ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(1.4), value: showFeatures)

            if let offering, PaywallView.hasTrialOrPromotionalOffer(in: offering) {
                HStack {
                    Text(localized("paywall.remind_before_trial_ends", defaultValue: "Remind me before trial ends"))
                        .font(typography.subtitle)
                        .foregroundColor(primaryTextColor)

                    Spacer()

                    Toggle("", isOn: $remindBeforeTrialEnds)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: accentColor))
                        .scaleEffect(0.8)
                        .frame(width: 44, alignment: .trailing)
                        .onChange(of: remindBeforeTrialEnds) { _, newValue in
                            Task {
                                await handleReminderToggleChange(newValue: newValue)
                            }
                        }
                }
                .opacity(showFeatures ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(1.6), value: showFeatures)
            }

            VStack(spacing: 6) {
                if configuration.privacyPolicyURL != nil || configuration.termsOfServiceURL != nil {
                    HStack(spacing: 8) {
                        if configuration.privacyPolicyURL != nil {
                            Button(localized("paywall.privacy_policy", defaultValue: "Privacy Policy")) {
                                openLink(configuration.privacyPolicyURL)
                            }
                            .font(typography.footnote)
                            .foregroundColor(secondaryTextColor)
                            .underline(true)
                        }
                        
                        Button(localized("paywall.restore_purchases", defaultValue: "Restore Purchases")) {
                            restorePurchases()
                        }
                        .font(typography.footnote)
                        .foregroundColor(secondaryTextColor)
                        .underline(true)

                        if configuration.termsOfServiceURL != nil {
                            Button(localized("paywall.terms_of_service", defaultValue: "Terms of Service")) {
                                openLink(configuration.termsOfServiceURL)
                            }
                            .font(typography.footnote)
                            .foregroundColor(secondaryTextColor)
                            .underline(true)
                        }
                    }
                }

//                Text("Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.")
//                    .font(typography.footnote)
//                    .foregroundColor(mutedTextColor)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 24)
//                    .lineLimit(geometry.size.height < 700 ? 4 : 3)
            }
            .opacity(showFeatures ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(1.8), value: showFeatures)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, max(30, geometry.safeAreaInsets.bottom + 20))
    }

    private var ctaButtonText: String {
        guard selectedPackage != nil else { return localized("paywall.cta.unlock_premium", defaultValue: "Unlock Premium") }
        return localized("paywall.cta.unlock_premium", defaultValue: "Unlock Premium")
    }

    @MainActor
    private func loadOffering() async {
        guard !configuration.revenueCatPublicKey.isEmpty else {
            isLoading = false
            return
        }

        do {
            let offerings = try await Purchases.shared.offerings()
            if
                let identifier = configuration.offeringIdentifier,
                let specific = offerings.all[identifier] {
                offering = specific
            } else if let current = offerings.current {
                offering = current
            } else {
                offering = offerings.all.values.first
            }

            if let offering {
                selectInitialPackage(from: offering)
            }

            isLoading = false
        } catch {
            alertMessage = error.localizedDescription
            isLoading = false
        }
    }

    @MainActor
    private func selectInitialPackage(from offering: Offering) {
        selectedPackage = PaywallView.initialSelection(from: offering)
    }

    @MainActor
    private func handleReminderToggleChange(newValue: Bool) async {
        guard newValue else {
            remindBeforeTrialEnds = false
            return
        }

        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            remindBeforeTrialEnds = true
        case .notDetermined:
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            remindBeforeTrialEnds = granted
        case .denied:
            remindBeforeTrialEnds = false
        @unknown default:
            remindBeforeTrialEnds = false
        }
    }

    @MainActor
    private func purchaseSelectedPackage() {
        guard shouldLoadOfferingFromNetwork else { return }
        guard let package = selectedPackage else { return }
        Task {
            await purchase(package: package)
        }
    }

    @MainActor
    private func purchase(package: Package) async {
        isPurchasing = true
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if !result.userCancelled {
                let hasActiveEntitlements = !result.customerInfo.entitlements.active.isEmpty
                subscriptionManager.persistPremium(hasActiveEntitlements)
                try? await Task.sleep(nanoseconds: 500_000_000)
                dismiss()
            }
        } catch {
            alertMessage = error.localizedDescription
        }
        isPurchasing = false
    }

    @MainActor
    private func restorePurchases() {
        guard shouldLoadOfferingFromNetwork else { return }
        Task {
            do {
                let customerInfo = try await Purchases.shared.restorePurchases()
                let hasActiveEntitlements = !customerInfo.entitlements.active.isEmpty
                if hasActiveEntitlements {
                    subscriptionManager.persistPremium(hasActiveEntitlements)
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    dismiss()
                } else {
                    alertMessage = localized("paywall.alert.no_purchases", defaultValue: "No previous purchases found to restore.")
                }
            } catch {
                alertMessage = localizer.format(
                    "paywall.alert.restore_failed",
                    defaultValue: "Failed to restore purchases: %@",
                    error.localizedDescription
                )
            }
        }
    }

    @MainActor
    private func openLink(_ url: URL?) {
        guard let url else { return }
        openURL(url)
    }

    private static func initialSelection(from offering: Offering?) -> Package? {
        guard let offering else { return nil }

        if let preferred = offering.availablePackages.first(where: { $0.packageType != .weekly }) {
            return preferred
        }

        return offering.availablePackages.first
    }

    private static func hasTrialOrPromotionalOffer(in offering: Offering) -> Bool {
        offering.availablePackages.contains(where: { $0.storeProduct.introductoryDiscount != nil })
    }

    private func localized(_ key: String, defaultValue: String) -> String {
        localizer.string(key, defaultValue: defaultValue)
    }
}
