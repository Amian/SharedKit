import Foundation
import SwiftData

@available(iOS 17.0, macOS 14.0, *)
@Model
final class PaywallSettings {
    var lastUpdated: Date
    var premiumUnlocked: Bool

    init(premiumUnlocked: Bool = false, lastUpdated: Date = .now) {
        self.lastUpdated = lastUpdated
        self.premiumUnlocked = premiumUnlocked
    }
}
