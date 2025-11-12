import SwiftUI
import RevenueCat

struct CompactPremiumPackageCard: View {
    @Environment(\.colorScheme) private var colorScheme

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

    private var isPopular: Bool {
        package.packageType == .annual || package.packageType == .sixMonth
    }

    private var savings: String? {
        switch package.packageType {
        case .annual:
            return "Save 60%"
        case .sixMonth:
            return "Save 40%"
        default:
            return nil
        }
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(package.storeProduct.localizedTitle)
                            .font(typography.headingLarge)
                            .foregroundColor(primaryTextColor)

                        if isPopular {
                            Text("POPULAR")
                                .font(typography.labelCaps)
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.yellow)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }

                    if let savings {
                        Text(savings)
                            .font(typography.body)
                            .foregroundColor(.green)
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
                        Text("per year")
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
            return "Billed monthly"
        case .annual:
            return "Billed annually"
        case .sixMonth:
            return "Billed every 6 months"
        case .twoMonth:
            return "Billed every 2 months"
        case .threeMonth:
            return "Billed quarterly"
        case .weekly:
            return "Billed weekly"
        default:
            return "One-time purchase"
        }
    }
}

struct UltraCompactPackageCard: View {
    @Environment(\.colorScheme) private var colorScheme

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

    private var isPopular: Bool {
        package.packageType == .annual || package.packageType == .sixMonth
    }

    private var savings: String? {
        switch package.packageType {
        case .annual:
            return "Save 60%"
        case .sixMonth:
            return "Save 40%"
        default:
            return nil
        }
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 4) {
                        Text(package.storeProduct.localizedTitle)
                            .font(isSmallScreen ? typography.headingSmall : typography.headingLarge)
                            .foregroundColor(primaryTextColor)

                        if isPopular {
                            Text("POPULAR")
                                .font(typography.labelCaps)
                                .foregroundColor(.black)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.yellow)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }

                    if let savings {
                        Text(savings)
                            .font(typography.body)
                            .foregroundColor(.green)
                    }

                    if showFreeTrial, package.storeProduct.introductoryDiscount != nil {
                        Text(freeTrialDurationText)
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

                        Text("Free")
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

        let durationText: String
        switch periodUnit {
        case .day:
            durationText = periodValue == 1 ? "1 day" : "\(periodValue) days"
        case .week:
            durationText = periodValue == 1 ? "1 week" : "\(periodValue) weeks"
        case .month:
            durationText = periodValue == 1 ? "1 month" : "\(periodValue) months"
        case .year:
            durationText = periodValue == 1 ? "1 year" : "\(periodValue) years"
        @unknown default:
            durationText = "trial period"
        }

        let regularPrice = package.storeProduct.localizedPriceString
        let billingPeriod = package.packageType == .weekly ? "/week" : "/month"

        return "Free for \(durationText), then \(regularPrice)\(billingPeriod)"
    }
}
