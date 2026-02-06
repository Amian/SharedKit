import SwiftUI
#if os(iOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

@available(iOS 17.0, macOS 11.0, *)
enum OnboardingTextGradientEdge {
    case top
    case bottom
}

@available(iOS 17.0, macOS 11.0, *)
struct OnboardingTextBounds: Equatable {
    var title: CGRect?
    var subtitle: CGRect?
}

@available(iOS 17.0, macOS 11.0, *)
struct OnboardingTextBoundsPreferenceKey: PreferenceKey {
    static let defaultValue = OnboardingTextBounds(title: nil, subtitle: nil)

    static func reduce(value: inout OnboardingTextBounds, nextValue: () -> OnboardingTextBounds) {
        let next = nextValue()
        if let title = next.title {
            value.title = title
        }
        if let subtitle = next.subtitle {
            value.subtitle = subtitle
        }
    }
}

@available(iOS 17.0, macOS 11.0, *)
extension View {
    func onboardingTitleBounds(in coordinateSpace: String) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: OnboardingTextBoundsPreferenceKey.self,
                    value: OnboardingTextBounds(title: proxy.frame(in: .named(coordinateSpace)), subtitle: nil)
                )
            }
        )
    }

    func onboardingSubtitleBounds(in coordinateSpace: String) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: OnboardingTextBoundsPreferenceKey.self,
                    value: OnboardingTextBounds(title: nil, subtitle: proxy.frame(in: .named(coordinateSpace)))
                )
            }
        )
    }
}

@available(iOS 17.0, macOS 11.0, *)
struct OnboardingTextGradientOverlay: View {
    let textBoundaryY: CGFloat
    let containerHeight: CGFloat
    let edge: OnboardingTextGradientEdge
    let baseColor: Color
    var maxOpacity: CGFloat = 0.58
    var edgePadding: CGFloat = 16
    var opaqueStop: CGFloat = 0.32

    var body: some View {
        if let height = gradientHeight {
            LinearGradient(
                gradient: Gradient(stops: gradientStops),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .frame(maxHeight: .infinity, alignment: alignment)
            .ignoresSafeArea(edges: ignoredEdges)
            .allowsHitTesting(false)
        }
    }

    private var gradientHeight: CGFloat? {
        guard containerHeight > 0 else { return nil }
        let rawHeight: CGFloat
        switch edge {
        case .top:
            rawHeight = textBoundaryY + edgePadding
        case .bottom:
            rawHeight = containerHeight - textBoundaryY + edgePadding
        }
        return min(containerHeight, max(0, rawHeight))
    }

    private var alignment: Alignment {
        edge == .top ? .top : .bottom
    }

    private var ignoredEdges: Edge.Set {
        edge == .top ? .top : .bottom
    }

    private var gradientStops: [Gradient.Stop] {
        let clampedStop = min(max(opaqueStop, 0), 1)
        switch edge {
        case .top:
            return [
                .init(color: baseColor.opacity(maxOpacity), location: 0),
                .init(color: baseColor.opacity(maxOpacity), location: clampedStop),
                .init(color: baseColor.opacity(0), location: 1)
            ]
        case .bottom:
            return [
                .init(color: baseColor.opacity(0), location: 0),
                .init(color: baseColor.opacity(maxOpacity), location: 1 - clampedStop),
                .init(color: baseColor.opacity(maxOpacity), location: 1)
            ]
        }
    }
}

@available(iOS 17.0, macOS 11.0, *)
extension Color {
    func isPerceivedLight(resolvedFor scheme: ColorScheme) -> Bool {
        #if os(iOS)
        let style: UIUserInterfaceStyle = scheme == .dark ? .dark : .light
        let resolved = UIColor(self).resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        guard resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return scheme == .dark
        }
        #elseif os(macOS)
        let appearanceName: NSAppearance.Name = scheme == .dark ? .darkAqua : .aqua
        let appearance = NSAppearance(named: appearanceName)
        let resolved = NSColor(self).resolvedColor(with: appearance ?? NSAppearance.current)
        let color = resolved.usingColorSpace(.sRGB) ?? resolved
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #else
        return scheme == .dark
        #endif
        let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
        return luminance > 0.6
    }
}
