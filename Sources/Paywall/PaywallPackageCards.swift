import SwiftUI
import RevenueCat
import DesignSystem

@available(iOS 17.0, macOS 11.0, *)
struct CompactPremiumPackageCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.designTypography) private var typography
    @Environment(\.paywallLocalization) private var paywallLocalization

    let package: Package
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

    private var savings: String? {
        switch package.packageType {
        case .annual:
            return paywallLocalization.string("paywall.package.save_60", defaultValue: "Save 60%")
        case .sixMonth:
            return paywallLocalization.string("paywall.package.save_40", defaultValue: "Save 40%")
        default:
            return nil
        }
    }

    private var tagLabel: String? {
        return savings?.uppercased()
    }

    private var defaultSubtitle: String {
        switch package.packageType {
        case .monthly:
            return paywallLocalization.string("paywall.package.billed_monthly", defaultValue: "Billed monthly")
        case .annual:
            return paywallLocalization.string("paywall.package.billed_annually", defaultValue: "Billed annually")
        case .sixMonth:
            return paywallLocalization.string("paywall.package.billed_every_6_months", defaultValue: "Billed every 6 months")
        case .threeMonth:
            return paywallLocalization.string("paywall.package.billed_quarterly", defaultValue: "Billed quarterly")
        case .twoMonth:
            return paywallLocalization.string("paywall.package.billed_every_2_months", defaultValue: "Billed every 2 months")
        case .weekly:
            return paywallLocalization.string("paywall.package.billed_weekly", defaultValue: "Billed weekly")
        case .lifetime:
            return paywallLocalization.string("paywall.package.one_time", defaultValue: "One-time purchase")
        case .custom:
            return paywallLocalization.string("paywall.package.special_offer", defaultValue: "Special offer")
        case .unknown:
            return paywallLocalization.string("paywall.package.limited_offer", defaultValue: "Limited time offer")
        }
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
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.yellow)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }

                    Text(priceDescription)
                        .font(typography.subtitle)
                        .foregroundColor(secondaryTextColor)
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

    private var savings: String? {
        switch package.packageType {
        case .annual:
            return paywallLocalization.string("paywall.package.save_60", defaultValue: "Save 60%")
        case .sixMonth:
            return paywallLocalization.string("paywall.package.save_40", defaultValue: "Save 40%")
        default:
            return nil
        }
    }

    private var tagLabel: String? {
        return savings?.uppercased()
    }

    private var defaultSubtitle: String {
        switch package.packageType {
        case .monthly:
            return paywallLocalization.string("paywall.package.billed_monthly", defaultValue: "Billed monthly")
        case .annual:
            return paywallLocalization.string("paywall.package.billed_annually", defaultValue: "Billed annually")
        case .sixMonth:
            return paywallLocalization.string("paywall.package.billed_every_6_months", defaultValue: "Billed every 6 months")
        case .threeMonth:
            return paywallLocalization.string("paywall.package.billed_quarterly", defaultValue: "Billed quarterly")
        case .twoMonth:
            return paywallLocalization.string("paywall.package.billed_every_2_months", defaultValue: "Billed every 2 months")
        case .weekly:
            return paywallLocalization.string("paywall.package.billed_weekly", defaultValue: "Billed weekly")
        case .lifetime:
            return paywallLocalization.string("paywall.package.one_time", defaultValue: "One-time purchase")
        case .custom:
            return paywallLocalization.string("paywall.package.special_offer", defaultValue: "Special offer")
        case .unknown:
            return paywallLocalization.string("paywall.package.limited_offer", defaultValue: "Limited time offer")
        }
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
                                .foregroundColor(.black)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.yellow)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }

                    if showFreeTrial, package.storeProduct.introductoryDiscount != nil {
                        Text(freeTrialDurationText)
                            .font(typography.subtitle)
                            .foregroundColor(secondaryTextColor)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text(defaultSubtitle)
                            .font(typography.subtitle)
                            .foregroundColor(secondaryTextColor)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    if package.storeProduct.introductoryDiscount != nil {
                        Text(package.storeProduct.localizedPriceString)
                            .font(typography.emphasisSecondary)
                            .foregroundColor(.gray)
                            .strikethrough()

                        Text(paywallLocalization.string("paywall.package.free", defaultValue: "FREE"))
                            .font(typography.emphasisPrimary)
                            .foregroundColor(.green)
                    } else {
                        Text(package.storeProduct.localizedPriceString)
                            .font(typography.emphasisPrimary)
                            .foregroundColor(primaryTextColor)
                    }
                }

                ZStack {
                    Circle()
                        .fill(isSelected ? accentColor : borderColor)
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
                    .fill(isSelected ? accentColor.opacity(0.2) : surfaceColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
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

    private var freeTrialDurationText: String {
        guard let introDiscount = package.storeProduct.introductoryDiscount else {
            return ""
        }

        let periodUnit = introDiscount.subscriptionPeriod.unit
        let periodValue = introDiscount.subscriptionPeriod.value

        let durationText = localizedDurationText(unit: periodUnit, value: periodValue)

        let regularPrice = package.storeProduct.localizedPriceString
        let billingPeriodKey = package.packageType == .weekly
            ? "paywall.package.billing_period.week"
            : "paywall.package.billing_period.month"
        let billingPeriodDefault = package.packageType == .weekly ? "/week" : "/month"
        let billingPeriod = paywallLocalization.string(billingPeriodKey, defaultValue: billingPeriodDefault)

        return paywallLocalization.format(
            "paywall.package.free_for_then",
            defaultValue: "Free for %@, then %@%@",
            durationText,
            regularPrice,
            billingPeriod
        )
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
