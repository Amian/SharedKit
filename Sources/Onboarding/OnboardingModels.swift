import SwiftUI
import DesignSystem

@available(iOS 17.0, macOS 11.0, *)
public enum OnboardingAppearancePreference: Hashable {
    case system
    case light
    case dark

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@available(iOS 17.0, macOS 11.0, *)
public struct OnboardingOption: Identifiable, Hashable {
    public let id: UUID
    public var title: String
    public var subtitle: String?
    public var iconName: String?
    public var iconColor: Color?

    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String? = nil,
        iconName: String? = nil,
        iconColor: Color? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.iconColor = iconColor
    }
}

@available(iOS 17.0, macOS 11.0, *)
public enum OnboardingInfoImagePlacement: Hashable {
    case top
    case betweenTitleAndSubtitle
    case bottom
}

@available(iOS 17.0, macOS 11.0, *)
public enum OnboardingInfoAccessoryPlacement: Hashable {
    case aboveImage
    case afterContentBeforeCTA
}

@available(iOS 17.0, macOS 11.0, *)
public struct OnboardingInfoStep: Hashable {
    public var imageName: String?
    public var gifName: String?
    public var title: String
    public var subtitle: String?
    public var ctaTitle: String
    public var accentColor: Color
    public var backgroundColor: Color
    public var appearance: OnboardingAppearancePreference
    public var imagePlacement: OnboardingInfoImagePlacement
    public var accessoryPlacement: OnboardingInfoAccessoryPlacement
    public var accessory: AnyView?

    public init(
        imageName: String? = nil,
        gifName: String? = nil,
        title: String,
        subtitle: String? = nil,
        ctaTitle: String = "Continue",
        accentColor: Color = Color.green,
        backgroundColor: Color = .designSystemBackground,
        appearance: OnboardingAppearancePreference = .system,
        imagePlacement: OnboardingInfoImagePlacement = .top,
        accessoryPlacement: OnboardingInfoAccessoryPlacement = .afterContentBeforeCTA,
        accessory: AnyView? = nil
    ) {
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.ctaTitle = ctaTitle
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.appearance = appearance
        self.imagePlacement = imagePlacement
        self.accessoryPlacement = accessoryPlacement
        self.accessory = accessory
        self.gifName = gifName
    }

    public init<Accessory: View>(
        imageName: String? = nil,
        gifName: String? = nil,
        title: String,
        subtitle: String? = nil,
        ctaTitle: String = "Continue",
        accentColor: Color = Color.green,
        backgroundColor: Color = .designSystemBackground,
        appearance: OnboardingAppearancePreference = .system,
        imagePlacement: OnboardingInfoImagePlacement = .top,
        accessoryPlacement: OnboardingInfoAccessoryPlacement = .afterContentBeforeCTA,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.init(
            imageName: imageName,
            gifName: gifName, title: title,
            subtitle: subtitle,
            ctaTitle: ctaTitle,
            accentColor: accentColor,
            backgroundColor: backgroundColor,
            appearance: appearance,
            imagePlacement: imagePlacement,
            accessoryPlacement: accessoryPlacement,
            accessory: AnyView(accessory())
        )
    }

    public static func == (lhs: OnboardingInfoStep, rhs: OnboardingInfoStep) -> Bool {
        lhs.imageName == rhs.imageName &&
        lhs.gifName == rhs.gifName &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle &&
        lhs.ctaTitle == rhs.ctaTitle &&
        lhs.accentColor == rhs.accentColor &&
        lhs.backgroundColor == rhs.backgroundColor &&
        lhs.appearance == rhs.appearance &&
        lhs.imagePlacement == rhs.imagePlacement &&
        lhs.accessoryPlacement == rhs.accessoryPlacement
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(imageName)
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(ctaTitle)
        hasher.combine(appearance)
        hasher.combine(imagePlacement)
        hasher.combine(accessoryPlacement)
        hasher.combine(gifName)
    }
}

@available(iOS 17.0, macOS 11.0, *)
public struct OnboardingQuestionStep: Hashable {
    public var imageName: String?
    public var title: String
    public var subtitle: String?
    public var allowsMultipleSelection: Bool
    public var options: [OnboardingOption]
    public var ctaTitle: String
    public var accentColor: Color
    public var backgroundColor: Color
    public var appearance: OnboardingAppearancePreference

    public init(
        imageName: String? = nil,
        title: String,
        subtitle: String? = nil,
        allowsMultipleSelection: Bool = false,
        options: [OnboardingOption],
        ctaTitle: String = "Continue",
        accentColor: Color = Color.green,
        backgroundColor: Color = .designSystemBackground,
        appearance: OnboardingAppearancePreference = .system
    ) {
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.allowsMultipleSelection = allowsMultipleSelection
        self.options = options
        self.ctaTitle = ctaTitle
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.appearance = appearance
    }
}

@available(iOS 17.0, macOS 11.0, *)
public enum OnboardingStep: Hashable {
    case info(OnboardingInfoStep)
    case question(OnboardingQuestionStep)
    case review(OnboardingReviewStep)
}

@available(iOS 17.0, macOS 11.0, *)
public struct OnboardingResponse {
    public let stepIndex: Int
    public let step: OnboardingStep
    public let selectedOptionIDs: [UUID]?
}

@available(iOS 17.0, macOS 11.0, *)
public struct OnboardingFlowConfiguration: Hashable {
    public var showsBreadcrumbs: Bool

    public init(showsBreadcrumbs: Bool = true) {
        self.showsBreadcrumbs = showsBreadcrumbs
    }
}

@available(iOS 17.0, macOS 11.0, *)
public struct OnboardingReviewStep: Hashable {
    public var imageName: String?
    public var title: String
    public var subtitle: String?
    public var ctaTitle: String
    public var accentColor: Color
    public var backgroundColor: Color
    public var appearance: OnboardingAppearancePreference

    public init(
        imageName: String? = nil,
        title: String,
        subtitle: String? = nil,
        ctaTitle: String = "Continue",
        accentColor: Color = Color.green,
        backgroundColor: Color = .designSystemBackground,
        appearance: OnboardingAppearancePreference = .system
    ) {
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.ctaTitle = ctaTitle
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.appearance = appearance
    }
}
