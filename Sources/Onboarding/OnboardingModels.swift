import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

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
        backgroundColor: Color = .onboardingSystemBackground,
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
        backgroundColor: Color = .onboardingSystemBackground,
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

public enum OnboardingStep: Hashable {
    case info(OnboardingInfoStep)
    case question(OnboardingQuestionStep)
}

public struct OnboardingResponse {
    public let stepIndex: Int
    public let step: OnboardingStep
    public let selectedOptionIDs: [UUID]?
}

public extension Color {
    static var onboardingSystemBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #elseif canImport(AppKit)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.white
        #endif
    }
}
