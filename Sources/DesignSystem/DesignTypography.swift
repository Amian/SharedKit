import SwiftUI

@available(iOS 17.0, *)
public struct DesignTypography: @unchecked Sendable {
    public let title: Font
    public let subtitle: Font
    public let body: Font
    public let cta: Font
    public let optionTitle: Font
    public let optionSubtitle: Font
    public let optionIcon: Font
    public let optionCheckmark: Font

    public init(
        title: Font,
        subtitle: Font,
        body: Font,
        cta: Font,
        optionTitle: Font,
        optionSubtitle: Font,
        optionIcon: Font,
        optionCheckmark: Font
    ) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.cta = cta
        self.optionTitle = optionTitle
        self.optionSubtitle = optionSubtitle
        self.optionIcon = optionIcon
        self.optionCheckmark = optionCheckmark
    }

    public static let `default` = DesignTypography(
        title: .system(size: 26, weight: .semibold),
        subtitle: .system(size: 13, weight: .regular),
        body: .system(size: 14, weight: .regular),
        cta: .system(size: 14, weight: .semibold),
        optionTitle: .system(size: 15, weight: .semibold),
        optionSubtitle: .system(size: 12, weight: .regular),
        optionIcon: .system(size: 18, weight: .semibold),
        optionCheckmark: .system(size: 10, weight: .bold)
    )
}

@available(iOS 17.0, *)
private struct DesignTypographyKey: EnvironmentKey {
    static let defaultValue: DesignTypography = .default
}

@available(iOS 17.0, *)
public extension EnvironmentValues {
    var designTypography: DesignTypography {
        get { self[DesignTypographyKey.self] }
        set { self[DesignTypographyKey.self] = newValue }
    }
}

@available(iOS 17.0, *)
public extension View {
    func designTypography(_ typography: DesignTypography) -> some View {
        environment(\.designTypography, typography)
    }
}
