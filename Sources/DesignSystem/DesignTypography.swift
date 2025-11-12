import SwiftUI

@available(iOS 17.0, macOS 10.15, *)
public struct DesignTypography: @unchecked Sendable {
    public let displayLarge: Font
    public let displayMedium: Font
    public let displaySubtitle: Font
    public let headingLarge: Font
    public let headingSmall: Font
    public let labelCaps: Font
    public let emphasisPrimary: Font
    public let emphasisSecondary: Font
    public let footnote: Font
    public let title: Font
    public let subtitle: Font
    public let body: Font
    public let button: Font
    public let listTitle: Font
    public let listSubtitle: Font
    public let iconLarge: Font
    public let iconSmall: Font

    public init(
        displayLarge: Font = .system(size: 28, weight: .bold, design: .rounded),
        displayMedium: Font = .system(size: 24, weight: .bold, design: .rounded),
        displaySubtitle: Font = .system(size: 15, weight: .medium),
        headingLarge: Font = .system(size: 18, weight: .semibold),
        headingSmall: Font = .system(size: 14, weight: .regular),
        labelCaps: Font = .system(size: 11, weight: .bold),
        emphasisPrimary: Font = .system(size: 18, weight: .bold),
        emphasisSecondary: Font = .system(size: 12, weight: .medium),
        footnote: Font = .system(size: 11, weight: .regular),
        title: Font = .system(size: 26, weight: .semibold),
        subtitle: Font = .system(size: 13, weight: .regular),
        body: Font = .system(size: 14, weight: .regular),
        button: Font = .system(size: 14, weight: .semibold),
        listTitle: Font = .system(size: 15, weight: .semibold),
        listSubtitle: Font = .system(size: 12, weight: .regular),
        iconLarge: Font = .system(size: 18, weight: .semibold),
        iconSmall: Font = .system(size: 10, weight: .bold)
    ) {
        self.displayLarge = displayLarge
        self.displayMedium = displayMedium
        self.displaySubtitle = displaySubtitle
        self.headingLarge = headingLarge
        self.headingSmall = headingSmall
        self.labelCaps = labelCaps
        self.emphasisPrimary = emphasisPrimary
        self.emphasisSecondary = emphasisSecondary
        self.footnote = footnote
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.button = button
        self.listTitle = listTitle
        self.listSubtitle = listSubtitle
        self.iconLarge = iconLarge
        self.iconSmall = iconSmall
    }

    public static let `default` = DesignTypography()
}

@available(iOS 17.0, macOS 10.15, *)
private struct DesignTypographyKey: EnvironmentKey {
    static let defaultValue: DesignTypography = .default
}

@available(iOS 17.0, macOS 10.15, *)
public extension EnvironmentValues {
    var designTypography: DesignTypography {
        get { self[DesignTypographyKey.self] }
        set { self[DesignTypographyKey.self] = newValue }
    }
}

@available(iOS 17.0, macOS 10.15, *)
public extension View {
    func designTypography(_ typography: DesignTypography) -> some View {
        environment(\.designTypography, typography)
    }
}
