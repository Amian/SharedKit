import SwiftUI
import RevenueCat

@available(iOS 17.0, macOS 14.0, *)
public struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var alertMessage: String?
    @State private var isLoading = true
    @State private var selectedPackage: Package?
    @State private var offering: Offering?
    @State private var isPurchasing = false
    @State private var showFeatures = false
    @State private var showFreeTrial = false
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    adaptivePaywallContent(geometry: geometry)
                        .frame(minHeight: geometry.size.height)
                }
                .scrollIndicators(.hidden)
            }
        }
        .task { await loadOffering() }
        .onAppear(perform: startAnimations)
        .onReceive(subscriptionManager.$isPremium, perform: handlePremiumChange(_:))
        .alert("Message", isPresented: .constant(alertMessage != nil)) {
            Button("OK") { alertMessage = nil }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    @MainActor
    private func startAnimations() {
        subscriptionManager.configureIfPossible()
        withAnimation {
            showFeatures = true
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
        VStack(spacing: geometry.size.height < 700 ? 8 : 12) {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .opacity(showFeatures ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(0.2), value: showFeatures)

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.paywallAccent.opacity(0.3), Color.paywallAccent.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geometry.size.height < 700 ? 80 : 100, height: geometry.size.height < 700 ? 80 : 100)

                Image(systemName: "crown.fill")
                    .font(.system(size: geometry.size.height < 700 ? 32 : 40, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.paywallAccent.opacity(0.7), Color.paywallAccent]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(showFeatures ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: showFeatures)
            }

            VStack(spacing: 4) {
                Text("Unlock Premium")
                    .font(.system(size: geometry.size.height < 700 ? 24 : 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Track unlimited activities and unlock your full potential")
                    .font(.system(size: geometry.size.height < 700 ? 14 : 16, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }

    @ViewBuilder
    private func featureSection(for geometry: GeometryProxy) -> some View {
        let features = PaywallFeatureCatalog.highlighted
        if geometry.size.height >= 700 {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(features.prefix(4)) { feature in
                    CompactFeatureCard(feature: feature)
                        .opacity(showFeatures ? 1 : 0)
                        .offset(x: showFeatures ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(feature.delay), value: showFeatures)
                }
            }
            .padding(.horizontal, 20)
        } else {
            VStack(spacing: 8) {
                ForEach(Array(features.prefix(3).enumerated()), id: \.element.id) { entry in
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
            Text("Choose Your Plan")
                .font(.system(size: geometry.size.height < 700 ? 16 : 18, weight: .bold))
                .foregroundColor(.white)
                .opacity(showFeatures ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.8), value: showFeatures)

            if isLoading {
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .paywallAccent))
                    Text("Loading options…")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 16)
            } else if let offering {
                VStack(spacing: 8) {
                    if let weeklyPackage = offering.availablePackages.first(where: { $0.packageType == .weekly }),
                       weeklyPackage.storeProduct.introductoryDiscount != nil {
                        HStack {
                            Text("Free Trial")
                                .font(.system(size: geometry.size.height < 700 ? 16 : 18, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .paywallAccent.opacity(0.5), radius: 2, x: 0, y: 1)

                            Spacer()

                            Toggle("", isOn: $showFreeTrial)
                                .toggleStyle(SwitchToggleStyle(tint: .paywallAccent))
                                .scaleEffect(0.8)
                                .onChange(of: showFreeTrial) { _, newValue in
                                    handleFreeTrialToggle(newValue: newValue)
                                }
                        }
                        .opacity(showFeatures ? 1 : 0)
                        .animation(.easeOut(duration: 0.6).delay(0.9), value: showFeatures)
                    }

                    let packages = offering.availablePackages.sorted(by: { $0.packageType.rawValue > $1.packageType.rawValue })
                    ForEach(packages, id: \.identifier) { package in
                        UltraCompactPackageCard(
                            package: package,
                            isSelected: selectedPackage?.identifier == package.identifier,
                            onSelect: { selectedPackage = package },
                            isSmallScreen: geometry.size.height < 700,
                            showFreeTrial: showFreeTrial && package.packageType == .weekly
                        )
                        .opacity(showFeatures ? 1 : 0)
                        .offset(y: showFeatures ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(1.0), value: showFeatures)
                    }
                }
            } else {
                Text("No packages available right now. Please try again later.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
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

                Text(isPurchasing ? "Processing..." : ctaButtonText)
                    .font(.system(size: geometry.size.height < 700 ? 15 : 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: geometry.size.height < 700 ? 44 : 48)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        selectedPackage != nil ? Color.paywallAccent : Color.gray,
                        selectedPackage != nil ? Color.paywallAccent.opacity(0.8) : Color.gray.opacity(0.8)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: geometry.size.height < 700 ? 22 : 24))
            .overlay(
                RoundedRectangle(cornerRadius: geometry.size.height < 700 ? 22 : 24)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: (selectedPackage != nil ? Color.paywallAccent : Color.gray).opacity(0.3), radius: 12, x: 0, y: 6)
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
                CompactTrustIndicator(icon: "lock.shield.fill", text: "Secure")
                CompactTrustIndicator(icon: "arrow.clockwise", text: "Cancel Anytime")
                CompactTrustIndicator(icon: "checkmark.seal.fill", text: "No Hidden Fees")
            }
            .opacity(showFeatures ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(1.4), value: showFeatures)

            Button(action: restorePurchases) {
                Text("Restore Purchases")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .opacity(showFeatures ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(1.6), value: showFeatures)

            VStack(spacing: 6) {
                HStack(spacing: 12) {
                    Button("Privacy Policy") {
                        openLink("https://amian.github.io/privacy-general")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)

                    Text("•")
                        .foregroundColor(.gray.opacity(0.5))
                        .font(.system(size: 10))

                    Button("Terms of Service") {
                        openLink("https://amian.github.io/terms")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
                }

                Text("Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.")
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.gray.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .lineLimit(geometry.size.height < 700 ? 4 : 3)
            }
            .opacity(showFeatures ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(1.8), value: showFeatures)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, max(30, geometry.safeAreaInsets.bottom + 20))
    }

    private var ctaButtonText: String {
        guard let selectedPackage else { return "Start Premium" }
        if showFreeTrial && selectedPackage.packageType == .weekly,
           selectedPackage.storeProduct.introductoryDiscount != nil {
            return "Start Free Trial"
        }
        return "Start Premium"
    }

    @MainActor
    private func loadOffering() async {
        guard !RevenueCatConfig.publicSDKKey.isEmpty else {
            isLoading = false
            return
        }

        do {
            let offerings = try await Purchases.shared.offerings()
            if let specific = offerings.all[RevenueCatConfig.offeringIdentifier] {
                offering = specific
            } else if let current = offerings.current {
                offering = current
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
        let weekly = offering.availablePackages.first(where: { $0.packageType == .weekly })
        let hasFreeTrial = weekly?.storeProduct.introductoryDiscount != nil
        showFreeTrial = hasFreeTrial

        if hasFreeTrial, let weekly {
            selectedPackage = weekly
        } else if let preferred = offering.availablePackages.first(where: { $0.packageType != .weekly }) {
            selectedPackage = preferred
        } else {
            selectedPackage = offering.availablePackages.first
        }
    }

    @MainActor
    private func handleFreeTrialToggle(newValue: Bool) {
        guard let offering else { return }

        if newValue {
            if let weekly = offering.availablePackages.first(where: { $0.packageType == .weekly }) {
                selectedPackage = weekly
            }
        } else if let nonWeekly = offering.availablePackages.first(where: { $0.packageType != .weekly }) {
            selectedPackage = nonWeekly
        } else {
            selectedPackage = offering.availablePackages.first
        }
    }

    @MainActor
    private func purchaseSelectedPackage() {
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
        Task {
            do {
                let customerInfo = try await Purchases.shared.restorePurchases()
                let hasActiveEntitlements = !customerInfo.entitlements.active.isEmpty
                if hasActiveEntitlements {
                    subscriptionManager.persistPremium(hasActiveEntitlements)
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    dismiss()
                } else {
                    alertMessage = "No previous purchases found to restore."
                }
            } catch {
                alertMessage = "Failed to restore purchases: \(error.localizedDescription)"
            }
        }
    }

    @MainActor
    private func openLink(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        openURL(url)
    }
}
