# AppBrowser

SwiftUI components and data loading for showcasing a list of apps or subjects.

## Requirements
- iOS 17+
- Swift Concurrency

## Data format
The source URL must return a JSON array of listings:
```json
[
  {
    "subject": "physics",
    "name": "Physics",
    "appleId": "6755822978",
    "imageUrl": "https://example.com/physics.png",
    "link": "https://example.com/physics"
  }
]
```
- `subject` is the identifier (also accepted as `app`, `slug`, or `id`).
- `name` is required; if omitted the identifier is used for display.
- Optional keys: `appleId`, `imageUrl`, `link` (also accepts `appStoreId`, `image_url`, `url`).
- If `imageUrl` is missing or empty, `AppListing.imageURL(using:)` falls back to `imageBaseURL/<app>.png`.

## Quick start (SwiftUI)
```swift
import AppBrowser

@available(iOS 17.0, *)
struct ContentView: View {
    private let source = URL(string: "https://example.com/apps.json")!

    var body: some View {
        AppBrowserView(
            sourceURL: source,
            imageBaseURL: URL(string: "https://example.com/images"),
            excludeAppId: "my-app-id"
        )
    }
}
```

## Repository-only usage
If you only need the data:
```swift
let repo = AppBrowserRepository(
    sourceURL: URL(string: "https://example.com/apps.json")!,
    imageBaseURL: nil,
    excludeAppId: nil
)

Task {
    await repo.load()        // loads cache then fetches remote
    let apps = repo.apps     // filtered and decoded array
}
```

## Configuration
`AppBrowserConfiguration` controls layout: card height, corner radius, padding, gradient height, background color, and content mode.
Pass a custom configuration to `AppBrowserView`:
```swift
let config = AppBrowserConfiguration(
    cardHeight: 220,
    cornerRadius: 16,
    backgroundColor: .black.opacity(0.9),
    contentMode: .fit
)

AppBrowserView(sourceURL: source, configuration: config)
```

## Caching
Fetched JSON is cached under `app-browser-<sanitized-url>.json` in the user's caches directory. Cache is read on startup and replaced after successful fetch.
