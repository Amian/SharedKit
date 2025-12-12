import Foundation

public struct AppListing: Codable, Identifiable, Hashable {
    public let app: String
    public let name: String
    public let appleId: String?
    public let imageUrl: String?
    public let link: String?

    public var id: String { app }

    public init(
        app: String,
        name: String,
        appleId: String? = nil,
        imageUrl: String? = nil,
        link: String? = nil
    ) {
        self.app = app
        self.name = name
        self.appleId = appleId
        self.imageUrl = imageUrl
        self.link = link
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedApp = try container.decodeIfPresent(String.self, forKey: .app)
            ?? container.decodeIfPresent(String.self, forKey: .subject)
            ?? container.decodeIfPresent(String.self, forKey: .slug)
            ?? container.decodeIfPresent(String.self, forKey: .id)
        let decodedName = try container.decodeIfPresent(String.self, forKey: .name)

        guard let appValue = decodedApp ?? decodedName?.lowercased() else {
            throw DecodingError.dataCorruptedError(
                forKey: .app,
                in: container,
                debugDescription: "App identifier missing"
            )
        }

        app = appValue
        name = decodedName ?? appValue
        appleId = try container.decodeIfPresent(String.self, forKey: .appleId)
            ?? container.decodeIfPresent(String.self, forKey: .appStoreId)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
            ?? container.decodeIfPresent(String.self, forKey: .imageURLSnakeCase)
        link = try container.decodeIfPresent(String.self, forKey: .link)
            ?? container.decodeIfPresent(String.self, forKey: .url)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(app, forKey: .app)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(appleId, forKey: .appleId)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(link, forKey: .link)
    }

    public func imageURL(using imageBaseURL: URL?) -> URL? {
        if let imageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
            return url
        }

        guard let imageBaseURL else { return nil }
        return imageBaseURL.appendingPathComponent("\(app).png")
    }

    public var destinationURL: URL? {
        if let link, let url = URL(string: link) {
            return url
        }

        if let appleId {
            return URL(string: "https://apps.apple.com/app/id\(appleId)")
        }

        return nil
    }

    private enum CodingKeys: String, CodingKey {
        case app
        case name
        case appleId
        case imageUrl
        case link
        case subject
        case slug
        case id
        case appStoreId
        case imageURLSnakeCase = "image_url"
        case url
    }
}
