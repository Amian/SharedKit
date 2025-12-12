import SwiftUI

public struct AppBrowserConfiguration {
    public var cardHeight: CGFloat
    public var cornerRadius: CGFloat
    public var horizontalPadding: CGFloat
    public var verticalPadding: CGFloat
    public var verticalSpacing: CGFloat
    public var gradientHeight: CGFloat
    public var backgroundColor: Color
    public var contentMode: ContentMode

    public init(
        cardHeight: CGFloat = 240,
        cornerRadius: CGFloat = 18,
        horizontalPadding: CGFloat = 20,
        verticalPadding: CGFloat = 24,
        verticalSpacing: CGFloat = 20,
        gradientHeight: CGFloat = 86,
        backgroundColor: Color = Color(.systemGroupedBackground),
        contentMode: ContentMode = .fill
    ) {
        self.cardHeight = cardHeight
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.verticalSpacing = verticalSpacing
        self.gradientHeight = gradientHeight
        self.backgroundColor = backgroundColor
        self.contentMode = contentMode
    }
}

@available(iOS 17.0, *)
public struct AppBrowserView: View {
    @Environment(\.openURL) private var openURL

    @StateObject private var store: AppBrowserRepository
    private let configuration: AppBrowserConfiguration
    private let imageBaseURL: URL?
    private let onAppOpen: ((AppListing) -> Void)?

    public init(
        sourceURL: URL,
        imageBaseURL: URL? = nil,
        excludeAppId: String? = nil,
        configuration: AppBrowserConfiguration = AppBrowserConfiguration(),
        onAppOpen: ((AppListing) -> Void)? = nil
    ) {
        _store = StateObject(
            wrappedValue: AppBrowserRepository(
                sourceURL: sourceURL,
                imageBaseURL: imageBaseURL,
                excludeAppId: excludeAppId
            )
        )
        self.configuration = configuration
        self.imageBaseURL = imageBaseURL
        self.onAppOpen = onAppOpen
    }

    public init(
        repository: AppBrowserRepository,
        imageBaseURL: URL? = nil,
        configuration: AppBrowserConfiguration = AppBrowserConfiguration(),
        onAppOpen: ((AppListing) -> Void)? = nil
    ) {
        _store = StateObject(wrappedValue: repository)
        self.configuration = configuration
        self.imageBaseURL = imageBaseURL ?? repository.imageBaseURL
        self.onAppOpen = onAppOpen
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: configuration.verticalSpacing) {
                ForEach(store.apps) { app in
                    AppCard(
                        app: app,
                        imageURL: app.imageURL(using: imageBaseURL),
                        configuration: configuration
                    ) {
                        handleTap(app)
                    }
                }
            }
            .padding(.horizontal, configuration.horizontalPadding)
            .padding(.vertical, configuration.verticalPadding)
        }
        .task {
            await store.load()
        }
        .background(configuration.backgroundColor.ignoresSafeArea())
    }

    private func handleTap(_ app: AppListing) {
        if let onAppOpen {
            onAppOpen(app)
            return
        }

        if let destination = app.destinationURL {
            openURL(destination)
        }
    }
}

@available(iOS 17.0, *)
private struct AppCard: View {
    let app: AppListing
    let imageURL: URL?
    let configuration: AppBrowserConfiguration
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                CachedAsyncImage(url: imageURL, contentMode: configuration.contentMode) {
                    RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous)
                        .fill(Color.secondary.opacity(0.12))
                        .overlay(ProgressView())
                }
                .frame(maxWidth: .infinity, minHeight: configuration.cardHeight, maxHeight: configuration.cardHeight)
                .clipped()
                .cornerRadius(configuration.cornerRadius)

                LinearGradient(
                    colors: [Color.black.opacity(0.8), Color.black.opacity(0.7), Color.black.opacity(0.6), Color.black.opacity(0.4), Color.black.opacity(0.05), Color.clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: configuration.gradientHeight)
                .cornerRadius(configuration.cornerRadius)
                .overlay(
                    Text(app.name)
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12),
                    alignment: .bottomLeading
                )
            }
        }
        .buttonStyle(.plain)
    }
}
