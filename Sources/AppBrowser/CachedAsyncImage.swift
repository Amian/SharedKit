import Combine
import SwiftUI
import UIKit

@MainActor
private final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

@MainActor
private final class CachedImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var task: URLSessionDataTask?

    func load(url: URL?) {
        guard let url else {
#if DEBUG
            print("CachedImageLoader: no URL provided")
#endif
            return
        }
        let key = url as NSURL

        if let cached = ImageCache.shared.object(forKey: key) {
#if DEBUG
            print("CachedImageLoader: using cached image for \(url.absoluteString)")
#endif
            image = cached
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad

        task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self else { return }
            if let error {
#if DEBUG
                print("CachedImageLoader: failed to fetch \(url.absoluteString) - \(error.localizedDescription)")
#endif
                return
            }
            if let data, let uiImage = UIImage(data: data) {
                ImageCache.shared.setObject(uiImage, forKey: key)
#if DEBUG
                print("CachedImageLoader: fetched image for \(url.absoluteString) (\(data.count) bytes)")
#endif
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            } else {
#if DEBUG
                print("CachedImageLoader: invalid image data for \(url.absoluteString)")
#endif
            }
        }
#if DEBUG
        print("CachedImageLoader: fetching image from \(url.absoluteString)")
#endif
        task?.resume()
    }

    func cancel() {
        task?.cancel()
    }
}

struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL?
    let contentMode: ContentMode
    @ViewBuilder var placeholder: () -> Placeholder

    @StateObject private var loader = CachedImageLoader()

    var body: some View {
        ZStack {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder()
            }
        }
        .onAppear {
            loader.load(url: url)
        }
        .onDisappear {
            loader.cancel()
        }
    }
}
