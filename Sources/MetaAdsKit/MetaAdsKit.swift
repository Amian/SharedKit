import Foundation
import FacebookCore

#if canImport(UIKit)
import UIKit

@MainActor
public enum MetaAdsKit {
    private static var isConfigured = false

    public static func configure(
        application: UIApplication,
        launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) {
        guard !isConfigured else { return }

        // Ensure settings are sourced from Info.plist while allowing overrides when needed.
        if let appID = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String,
           !appID.isEmpty {
            Settings.shared.appID = appID
        }

        if let clientToken = Bundle.main.object(forInfoDictionaryKey: "FacebookClientToken") as? String,
           !clientToken.isEmpty {
            Settings.shared.clientToken = clientToken
        }

        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        isConfigured = true
    }

    public static func activateApp() {
        AppEvents.shared.activateApp()
    }

    public static func handleOpenURL(
        _ app: UIApplication,
        url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(app, open: url, options: options)
    }
}
#endif
