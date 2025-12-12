import Combine
import Foundation

@MainActor
public final class AppBrowserRepository: ObservableObject {
    @Published public private(set) var apps: [AppListing] = []

    public let sourceURL: URL
    public let imageBaseURL: URL?
    public let excludeAppId: String?

    private let urlSession: URLSession
    private let cacheURL: URL

    public init(
        sourceURL: URL,
        imageBaseURL: URL? = nil,
        excludeAppId: String? = nil,
        urlSession: URLSession = .shared
    ) {
        self.sourceURL = sourceURL
        self.imageBaseURL = imageBaseURL
        self.excludeAppId = excludeAppId
        self.urlSession = urlSession
        cacheURL = Self.makeCacheURL(for: sourceURL)
    }

    public func load() async {
        await loadCached()
        await fetchRemote()
    }

    public func setPreviewApps(_ value: [AppListing]) {
        apps = filtered(value)
    }

    private func loadCached() async {
        guard FileManager.default.fileExists(atPath: cacheURL.path) else { return }
        do {
            let data = try Data(contentsOf: cacheURL)
            let decoded = try decodeApps(from: data)
            apps = filtered(decoded)
        } catch {
            print("AppBrowserRepository: cache load failed \(error)")
        }
    }

    private func fetchRemote() async {
        do {
            let (data, _) = try await urlSession.data(from: sourceURL)
            let decoded = try decodeApps(from: data)
            let filteredApps = filtered(decoded)
            apps = filteredApps
            try? data.write(to: cacheURL, options: .atomic)
        } catch {
            print("AppBrowserRepository: fetch failed \(error)")
        }
    }

    private func filtered(_ value: [AppListing]) -> [AppListing] {
        guard let excludeAppId else { return value }
        let target = excludeAppId.lowercased()
        return value.filter { $0.app.lowercased() != target }
    }

    private func decodeApps(from data: Data) throws -> [AppListing] {
        let decoder = JSONDecoder()
        if let payload = try? decoder.decode(AppListPayload.self, from: data) {
            if let apps = payload.apps {
                return apps
            }
            if let subjects = payload.subjects {
                return subjects
            }
        }
        return try decoder.decode([AppListing].self, from: data)
    }

    private static func makeCacheURL(for sourceURL: URL) -> URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let sanitized = Self.sanitizedFileName(from: sourceURL)
        return caches.appendingPathComponent("app-browser-\(sanitized).json", isDirectory: false)
    }

    private static func sanitizedFileName(from url: URL) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        return url.absoluteString.unicodeScalars.map { allowed.contains($0) ? String($0) : "_" }.joined()
    }
}

private struct AppListPayload: Codable {
    let apps: [AppListing]?
    let subjects: [AppListing]?
}
