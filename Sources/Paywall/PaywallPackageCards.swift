import SwiftUI
import RevenueCat
import DesignSystem

private struct PaywallPackageMarketingContent {
    let badgeText: String?
    let subtitleText: String?
}

private enum PaywallPackageMarketing {
    private struct SavingsComparison {
        let percentage: Int
        let referencePlanName: String
    }

    private struct PricingCandidate {
        let period: SubscriptionPeriod
        let unitPricePerDay: Double
    }

    static func content(
        for package: Package,
        among availablePackages: [Package],
        localizer: PaywallLocalization
    ) -> PaywallPackageMarketingContent {
        if let savingsComparison = savingsComparison(for: package, among: availablePackages, localizer: localizer) {
            return PaywallPackageMarketingContent(
                badgeText: localizer.format(
                    "paywall.package.save_dynamic",
                    defaultValue: "Save %d%%",
                    savingsComparison.percentage
                ),
                subtitleText: localizer.format(
                    "paywall.package.save_vs_plan",
                    defaultValue: "Save %d%% vs %@ plan",
                    savingsComparison.percentage,
                    savingsComparison.referencePlanName
                )
            )
        }

        return PaywallPackageMarketingContent(
            badgeText: nil,
            subtitleText: standardSubtitle(for: package, localizer: localizer)
        )
    }

    private static func standardSubtitle(for package: Package, localizer: PaywallLocalization) -> String? {
        if let billingText = billingDescription(for: package, localizer: localizer) {
            return localizer.format(
                "paywall.package.price_with_billing",
                defaultValue: "%@ %@",
                package.storeProduct.localizedPriceString,
                billingText
            )
        }

        if package.packageType == .lifetime {
            return localizer.format(
                "paywall.package.price_with_one_time_purchase",
                defaultValue: "%@ one-time purchase",
                package.storeProduct.localizedPriceString
            )
        }

        return package.storeProduct.localizedPriceString
    }

    private static func savingsComparison(
        for package: Package,
        among availablePackages: [Package],
        localizer: PaywallLocalization
    ) -> SavingsComparison? {
        guard let currentPeriod = package.storeProduct.subscriptionPeriod,
              let currentDurationInDays = durationInDays(for: currentPeriod),
              currentDurationInDays > 0 else {
            return nil
        }

        let currentUnitPricePerDay = unitPricePerDay(for: package, durationInDays: currentDurationInDays)
        guard currentUnitPricePerDay > 0 else {
            return nil
        }

        let candidates = availablePackages.compactMap { candidate -> PricingCandidate? in
            guard candidate.identifier != package.identifier,
                  let candidatePeriod = candidate.storeProduct.subscriptionPeriod,
                  let candidateDurationInDays = durationInDays(for: candidatePeriod),
                  candidateDurationInDays > 0,
                  candidateDurationInDays < currentDurationInDays else {
                return nil
            }

            let candidateUnitPricePerDay = unitPricePerDay(
                for: candidate,
                durationInDays: candidateDurationInDays
            )
            guard candidateUnitPricePerDay > 0 else {
                return nil
            }

            return PricingCandidate(
                period: candidatePeriod,
                unitPricePerDay: candidateUnitPricePerDay
            )
        }

        guard let baseline = candidates.max(by: { $0.unitPricePerDay < $1.unitPricePerDay }) else {
            return nil
        }

        let savingsPercentage = ((baseline.unitPricePerDay - currentUnitPricePerDay) / baseline.unitPricePerDay) * 100
        let roundedSavingsPercentage = Int(savingsPercentage.rounded())
        guard roundedSavingsPercentage > 0 else {
            return nil
        }

        return SavingsComparison(
            percentage: roundedSavingsPercentage,
            referencePlanName: planName(for: baseline.period, localizer: localizer)
        )
    }

    private static func billingDescription(for package: Package, localizer: PaywallLocalization) -> String? {
        guard let period = package.storeProduct.subscriptionPeriod else {
            return nil
        }

        switch period.unit {
        case .day:
            if period.value == 1 {
                return localizer.string("paywall.package.billed.day_one", defaultValue: "billed daily")
            }
            return localizer.format("paywall.package.billed.day_other", defaultValue: "billed every %d days", period.value)
        case .week:
            if period.value == 1 {
                return localizer.string("paywall.package.billed.week_one", defaultValue: "billed weekly")
            }
            return localizer.format("paywall.package.billed.week_other", defaultValue: "billed every %d weeks", period.value)
        case .month:
            if period.value == 1 {
                return localizer.string("paywall.package.billed.month_one", defaultValue: "billed monthly")
            }
            return localizer.format("paywall.package.billed.month_other", defaultValue: "billed every %d months", period.value)
        case .year:
            if period.value == 1 {
                return localizer.string("paywall.package.billed.year_one", defaultValue: "billed annually")
            }
            return localizer.format("paywall.package.billed.year_other", defaultValue: "billed every %d years", period.value)
        @unknown default:
            return nil
        }
    }

    private static func planName(for period: SubscriptionPeriod, localizer: PaywallLocalization) -> String {
        switch period.unit {
        case .day:
            if period.value == 1 {
                return localizer.string("paywall.package.plan_name.day_one", defaultValue: "daily")
            }
            return localizer.format("paywall.package.plan_name.day_other", defaultValue: "every %d days", period.value)
        case .week:
            if period.value == 1 {
                return localizer.string("paywall.package.plan_name.week_one", defaultValue: "weekly")
            }
            return localizer.format("paywall.package.plan_name.week_other", defaultValue: "every %d weeks", period.value)
        case .month:
            if period.value == 1 {
                return localizer.string("paywall.package.plan_name.month_one", defaultValue: "monthly")
            }
            return localizer.format("paywall.package.plan_name.month_other", defaultValue: "every %d months", period.value)
        case .year:
            if period.value == 1 {
                return localizer.string("paywall.package.plan_name.year_one", defaultValue: "annual")
            }
            return localizer.format("paywall.package.plan_name.year_other", defaultValue: "every %d years", period.value)
        @unknown default:
            return localizer.string("paywall.package.plan_name.default", defaultValue: "another")
        }
    }

    private static func durationInDays(for period: SubscriptionPeriod) -> Int? {
        switch period.unit {
        case .day:
            return period.value
        case .week:
            return period.value * 7
        case .month:
            return period.value * 30
        case .year:
            return period.value * 365
        @unknown default:
            return nil
        }
    }

    private static func unitPricePerDay(for package: Package, durationInDays: Int) -> Double {
        guard durationInDays > 0 else {
            return 0
        }

        let totalPrice = NSDecimalNumber(decimal: package.storeProduct.price).doubleValue
        guard totalPrice > 0 else {
            return 0
        }

        return totalPrice / Double(durationInDays)
    }
}

@available(iOS 17.0, macOS 11.0, *)
struct CompactPremiumPackageCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.designTypography) private var typography
    @Environment(\.paywallLocalization) private var paywallLocalization

    let package: Package
    let availablePackages: [Package]
    let isSelected: Bool
    let onSelect: () -> Void
    let accentColor: Color

    private var primaryTextColor: Color { colorScheme == .dark ? .white : .black }
    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7)
    }
    private var surfaceColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05)
    }
    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }

    private var marketingContent: PaywallPackageMarketingContent {
        PaywallPackageMarketing.content(
            for: package,
            among: availablePackages,
            localizer: paywallLocalization
        )
    }

    private var hasFreeTrial: Bool {
        package.storeProduct.introductoryDiscount != nil
    }

    private var tagLabel: String? {
        if hasFreeTrial {
            return paywallLocalization.string("paywall.package.free_trial_badge", defaultValue: "Free Trial").uppercased()
        }
        return marketingContent.badgeText?.uppercased()
    }

    private var defaultSubtitle: String? {
        marketingContent.subtitleText
    }

    private var tagTextColor: Color {
        hasFreeTrial ? .white : .black
    }

    private var tagBackgroundColor: Color {
        hasFreeTrial ? .green : .yellow
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(package.storeProduct.localizedTitle)
                            .font(typography.listTitle)
                            .foregroundColor(primaryTextColor)

                        if let tagLabel {
                            Text(tagLabel)
                                .font(typography.labelCaps)
                                .foregroundColor(tagTextColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(tagBackgroundColor)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }

                    if let defaultSubtitle {
                        Text(defaultSubtitle)
                            .font(typography.subtitle)
                            .foregroundColor(secondaryTextColor)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 1) {
                    Text(package.storeProduct.localizedPriceString)
                        .font(typography.emphasisPrimary)
                        .foregroundColor(primaryTextColor)

                    if package.packageType != .monthly {
                        Text(paywallLocalization.string("paywall.package.per_year", defaultValue: "per year"))
                            .font(typography.emphasisSecondary)
                            .foregroundColor(secondaryTextColor)
                    }
                }

                ZStack {
                    Circle()
                        .fill(isSelected ? accentColor : Color.white.opacity(0.2))
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(typography.iconSmall)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? accentColor.opacity(0.2) : surfaceColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? accentColor : borderColor,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }

    private var priceDescription: String {
        switch package.packageType {
        case .monthly:
            return paywallLocalization.string("paywall.package.billed_monthly", defaultValue: "Billed monthly")
        case .annual:
            return paywallLocalization.string("paywall.package.billed_annually", defaultValue: "Billed annually")
        case .sixMonth:
            return paywallLocalization.string("paywall.package.billed_every_6_months", defaultValue: "Billed every 6 months")
        case .twoMonth:
            return paywallLocalization.string("paywall.package.billed_every_2_months", defaultValue: "Billed every 2 months")
        case .threeMonth:
            return paywallLocalization.string("paywall.package.billed_quarterly", defaultValue: "Billed quarterly")
        case .weekly:
            return paywallLocalization.string("paywall.package.billed_weekly", defaultValue: "Billed weekly")
        default:
            return paywallLocalization.string("paywall.package.one_time", defaultValue: "One-time purchase")
        }
    }
}

@available(iOS 17.0, macOS 11.0, *)
struct UltraCompactPackageCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.designTypography) private var typography
    @Environment(\.paywallLocalization) private var paywallLocalization

    let package: Package
    let availablePackages: [Package]
    let isSelected: Bool
    let onSelect: () -> Void
    let isSmallScreen: Bool
    let showFreeTrial: Bool
    let accentColor: Color

    private var primaryTextColor: Color { colorScheme == .dark ? .white : .black }
    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.7) : Color.black.opacity(0.7)
    }
    private var surfaceColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05)
    }
    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }

    private var marketingContent: PaywallPackageMarketingContent {
        PaywallPackageMarketing.content(
            for: package,
            among: availablePackages,
            localizer: paywallLocalization
        )
    }

    private var hasFreeTrial: Bool {
        showFreeTrial && package.storeProduct.introductoryDiscount != nil
    }

    private var tagLabel: String? {
        if hasFreeTrial {
            return paywallLocalization.string("paywall.package.free_trial_badge", defaultValue: "Free Trial").uppercased()
        }
        return marketingContent.badgeText?.uppercased()
    }

    private var defaultSubtitle: String? {
        marketingContent.subtitleText
    }

    private var tagTextColor: Color {
        hasFreeTrial ? .white : .black
    }

    private var tagBackgroundColor: Color {
        hasFreeTrial ? .green : .yellow
    }

    private var cardFillColor: Color {
        if isSelected {
            return accentColor.opacity(0.2)
        }

        if hasFreeTrial {
            return accentColor.opacity(0.08)
        }

        return surfaceColor
    }

    private var cardStrokeColor: Color {
        if isSelected {
            return accentColor
        }

        if hasFreeTrial {
            return accentColor.opacity(0.65)
        }

        return borderColor
    }

    private var cardStrokeWidth: CGFloat {
        if isSelected {
            return 2
        }

        return hasFreeTrial ? 1.5 : 1
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 4) {
                    Text(package.storeProduct.localizedTitle)
                        .font(isSmallScreen ? typography.listSubtitle : typography.listTitle)
                        .foregroundColor(primaryTextColor)

                        if let tagLabel {
                            Text(tagLabel)
                                .font(typography.labelCaps)
                                .foregroundColor(tagTextColor)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(tagBackgroundColor)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }

                    if hasFreeTrial {
                        Text(freeTrialDurationText)
                            .font(typography.subtitle)
                            .foregroundColor(secondaryTextColor)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    } else if let defaultSubtitle {
                        Text(defaultSubtitle)
                            .font(typography.subtitle)
                            .foregroundColor(secondaryTextColor)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer()

                Text(package.storeProduct.localizedPriceString)
                    .font(typography.emphasisPrimary)
                    .foregroundColor(primaryTextColor)

                ZStack {
                    Circle()
                        .fill(isSelected ? accentColor : cardStrokeColor)
                        .frame(width: 16, height: 16)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(typography.iconSmall)
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(minHeight: isSmallScreen ? 44 : 48)
            .padding(.horizontal, 12)
            .padding(.vertical, isSmallScreen ? 8 : 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(cardFillColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                cardStrokeColor,
                                lineWidth: cardStrokeWidth
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }

    private var freeTrialDurationText: String {
        guard let introDiscount = package.storeProduct.introductoryDiscount else {
            return ""
        }

        let durationText = localizedDurationText(
            unit: introDiscount.subscriptionPeriod.unit,
            value: introDiscount.subscriptionPeriod.value
        )

        let regularPrice = package.storeProduct.localizedPriceString
        let billingPeriod = regularBillingPeriodText()

        return paywallLocalization.format(
            "paywall.package.free_for_then",
            defaultValue: "Free for %@, then %@%@",
            durationText,
            regularPrice,
            billingPeriod
        )
    }

    private func regularBillingPeriodText() -> String {
        if let subscriptionPeriod = package.storeProduct.subscriptionPeriod {
            return localizedBillingPeriodText(unit: subscriptionPeriod.unit, value: subscriptionPeriod.value)
        }

        switch package.packageType {
        case .weekly:
            return paywallLocalization.string("paywall.package.billing_period.week_one", defaultValue: "/week")
        case .monthly:
            return paywallLocalization.string("paywall.package.billing_period.month_one", defaultValue: "/month")
        case .annual:
            return paywallLocalization.string("paywall.package.billing_period.year_one", defaultValue: "/year")
        case .twoMonth:
            return paywallLocalization.format("paywall.package.billing_period.month_other", defaultValue: "/%d months", 2)
        case .threeMonth:
            return paywallLocalization.format("paywall.package.billing_period.month_other", defaultValue: "/%d months", 3)
        case .sixMonth:
            return paywallLocalization.format("paywall.package.billing_period.month_other", defaultValue: "/%d months", 6)
        default:
            return ""
        }
    }

    private func localizedBillingPeriodText(unit: SubscriptionPeriod.Unit, value: Int) -> String {
        switch unit {
        case .day:
            if value == 1 {
                return paywallLocalization.string("paywall.package.billing_period.day_one", defaultValue: "/day")
            }
            return paywallLocalization.format("paywall.package.billing_period.day_other", defaultValue: "/%d days", value)
        case .week:
            if value == 1 {
                return paywallLocalization.string("paywall.package.billing_period.week_one", defaultValue: "/week")
            }
            return paywallLocalization.format("paywall.package.billing_period.week_other", defaultValue: "/%d weeks", value)
        case .month:
            if value == 1 {
                return paywallLocalization.string("paywall.package.billing_period.month_one", defaultValue: "/month")
            }
            return paywallLocalization.format("paywall.package.billing_period.month_other", defaultValue: "/%d months", value)
        case .year:
            if value == 1 {
                return paywallLocalization.string("paywall.package.billing_period.year_one", defaultValue: "/year")
            }
            return paywallLocalization.format("paywall.package.billing_period.year_other", defaultValue: "/%d years", value)
        @unknown default:
            return ""
        }
    }

    private func localizedDurationText(unit: SubscriptionPeriod.Unit, value: Int) -> String {
        switch unit {
        case .day:
            if value == 1 {
                return paywallLocalization.string("paywall.package.duration.day_one", defaultValue: "1 day")
            }
            return paywallLocalization.format("paywall.package.duration.day_other", defaultValue: "%d days", value)
        case .week:
            if value == 1 {
                return paywallLocalization.string("paywall.package.duration.week_one", defaultValue: "1 week")
            }
            return paywallLocalization.format("paywall.package.duration.week_other", defaultValue: "%d weeks", value)
        case .month:
            if value == 1 {
                return paywallLocalization.string("paywall.package.duration.month_one", defaultValue: "1 month")
            }
            return paywallLocalization.format("paywall.package.duration.month_other", defaultValue: "%d months", value)
        case .year:
            if value == 1 {
                return paywallLocalization.string("paywall.package.duration.year_one", defaultValue: "1 year")
            }
            return paywallLocalization.format("paywall.package.duration.year_other", defaultValue: "%d years", value)
        @unknown default:
            return paywallLocalization.string("paywall.package.trial_period", defaultValue: "trial period")
        }
    }
}
