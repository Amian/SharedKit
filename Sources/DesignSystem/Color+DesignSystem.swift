import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 17.0, *)
public extension Color {
    /// Lightens the current color by blending it with white.
    func designLighten(by amount: CGFloat) -> Color {
        let normalizedAmount = min(max(amount, 0), 1)

        guard let cgColor = self.cgColor,
              let components = cgColor.components else {
            return self
        }

        let componentCount = cgColor.numberOfComponents
        let alphaIndex = min(componentCount - 1, components.count - 1)
        let alpha = components[alphaIndex]

        let (red, green, blue): (CGFloat, CGFloat, CGFloat)
        if componentCount >= 3 {
            red = components[0]
            green = components[1]
            blue = components[2]
        } else {
            red = components[0]
            green = components[0]
            blue = components[0]
        }

        func mixWithWhite(_ value: CGFloat) -> CGFloat {
            let clamped = min(max(value, 0), 1)
            return clamped + (1 - clamped) * normalizedAmount
        }

        return Color(
            red: Double(mixWithWhite(red)),
            green: Double(mixWithWhite(green)),
            blue: Double(mixWithWhite(blue)),
            opacity: Double(alpha)
        )
    }

    /// Darkens the current color by blending it with black.
    func designDarken(by amount: CGFloat) -> Color {
        let normalizedAmount = min(max(amount, 0), 1)

        guard let cgColor = self.cgColor,
              let components = cgColor.components else {
            return self
        }

        let componentCount = cgColor.numberOfComponents
        let alphaIndex = min(componentCount - 1, components.count - 1)
        let alpha = components[alphaIndex]

        let (red, green, blue): (CGFloat, CGFloat, CGFloat)
        if componentCount >= 3 {
            red = components[0]
            green = components[1]
            blue = components[2]
        } else {
            red = components[0]
            green = components[0]
            blue = components[0]
        }

        func mixWithBlack(_ value: CGFloat) -> CGFloat {
            let clamped = min(max(value, 0), 1)
            return clamped * (1 - normalizedAmount)
        }

        return Color(
            red: Double(mixWithBlack(red)),
            green: Double(mixWithBlack(green)),
            blue: Double(mixWithBlack(blue)),
            opacity: Double(alpha)
        )
    }

    static var designSystemBackground: Color {
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #else
        return Color.white
        #endif
    }
}
