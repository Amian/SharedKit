import Foundation
import SwiftUI

struct PaywallLocalization: Hashable {
    let bundlePath: String
    let table: String

    init(bundle: Bundle, table: String = "Localizable") {
        self.bundlePath = bundle.bundlePath
        self.table = table
    }

    var bundle: Bundle {
        Bundle(path: bundlePath) ?? .main
    }

    func string(_ key: String, defaultValue: String) -> String {
        bundle.localizedString(forKey: key, value: defaultValue, table: table)
    }

    func format(_ key: String, defaultValue: String, _ arguments: CVarArg...) -> String {
        let format = string(key, defaultValue: defaultValue)
        return String(format: format, locale: .current, arguments: arguments)
    }
}

private struct PaywallLocalizationKey: EnvironmentKey {
    static let defaultValue = PaywallLocalization(bundle: .main)
}

extension EnvironmentValues {
    var paywallLocalization: PaywallLocalization {
        get { self[PaywallLocalizationKey.self] }
        set { self[PaywallLocalizationKey.self] = newValue }
    }
}
