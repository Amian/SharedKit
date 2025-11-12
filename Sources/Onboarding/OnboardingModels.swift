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
public struct OnboardingInfoStep: Hashable {
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
}

@available(iOS 17.0, macOS 11.0, *)
public struct OnboardingResponse {
    public let stepIndex: Int
    public let step: OnboardingStep
    public let selectedOptionIDs: [UUID]?
}
