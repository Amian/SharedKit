import Foundation
import FirebaseAnalytics
import FirebaseCore
import FirebaseCrashlytics
import FirebaseRemoteConfig

@MainActor
public protocol AnalyticsClient {
    func logEvent(_ name: String, parameters: [String: Any]?)
    func setUserID(_ id: String?)
    func setUserProperty(_ value: String?, forName name: String)
}

@MainActor
public protocol CrashReporter {
    func log(_ message: String)
    func record(error: Error)
    func setUserID(_ id: String)
    func setCustomValue(_ value: Any?, forKey key: String)
}

@MainActor
public protocol RemoteConfigClient {
    func fetchAndActivate(completion: @escaping (Result<Void, Error>) -> Void)
    func string(forKey key: String) -> String?
    func bool(forKey key: String) -> Bool
    func number(forKey key: String) -> NSNumber
    func data(forKey key: String) -> Data
}

@MainActor
public enum FirebaseKit {
    public static let analytics: AnalyticsClient = FirebaseAnalyticsClient()
    public static let crashReporter: CrashReporter = FirebaseCrashlyticsClient()
    public static let remoteConfig: RemoteConfigClient = FirebaseRemoteConfigClient()

    private static var isConfigured = false

    public static func configure() {
        guard !isConfigured else { return }
        FirebaseApp.configure()
        isConfigured = true
    }

    static func assertConfigured() {
        if FirebaseApp.app() == nil {
            assertionFailure("Call FirebaseKit.configure() before using Firebase services.")
        }
    }
}

public enum FirebaseKitError: Error {
    case notConfigured
}

@MainActor
final class FirebaseAnalyticsClient: AnalyticsClient {
    func logEvent(_ name: String, parameters: [String: Any]?) {
        FirebaseKit.assertConfigured()
        Analytics.logEvent(name, parameters: parameters)
    }

    func setUserID(_ id: String?) {
        FirebaseKit.assertConfigured()
        Analytics.setUserID(id)
    }

    func setUserProperty(_ value: String?, forName name: String) {
        FirebaseKit.assertConfigured()
        Analytics.setUserProperty(value, forName: name)
    }
}

@MainActor
final class FirebaseCrashlyticsClient: CrashReporter {
    func log(_ message: String) {
        FirebaseKit.assertConfigured()
        Crashlytics.crashlytics().log(message)
    }

    func record(error: Error) {
        FirebaseKit.assertConfigured()
        Crashlytics.crashlytics().record(error: error)
    }

    func setUserID(_ id: String) {
        FirebaseKit.assertConfigured()
        Crashlytics.crashlytics().setUserID(id)
    }

    func setCustomValue(_ value: Any?, forKey key: String) {
        FirebaseKit.assertConfigured()
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
}

@MainActor
final class FirebaseRemoteConfigClient: RemoteConfigClient {
    private lazy var remoteConfig: RemoteConfig = {
        let config = RemoteConfig.remoteConfig()
        return config
    }()

    func fetchAndActivate(completion: @escaping (Result<Void, Error>) -> Void) {
        guard FirebaseApp.app() != nil else {
            assertionFailure("Call FirebaseKit.configure() before using Remote Config.")
            completion(.failure(FirebaseKitError.notConfigured))
            return
        }

        remoteConfig.fetchAndActivate { _, error in
            if let error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func string(forKey key: String) -> String? {
        FirebaseKit.assertConfigured()
        return remoteConfig.configValue(forKey: key).stringValue
    }

    func bool(forKey key: String) -> Bool {
        FirebaseKit.assertConfigured()
        return remoteConfig.configValue(forKey: key).boolValue
    }

    func number(forKey key: String) -> NSNumber {
        FirebaseKit.assertConfigured()
        return remoteConfig.configValue(forKey: key).numberValue
    }

    func data(forKey key: String) -> Data {
        FirebaseKit.assertConfigured()
        return remoteConfig.configValue(forKey: key).dataValue
    }
}
