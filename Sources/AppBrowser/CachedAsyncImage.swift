import Combine
import SwiftUI
import UIKit

private final class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

private final class CachedImageLoader: ObservableObject {
    @Published var image: UIImage?

    private var task: URLSessionDataTask?

    func load(url: URL?) {
        guard let url else { return }
        let key = url as NSURL

        if let cached = ImageCache.shared.object(forKey: key) {
            image = cached
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad

        task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let self else { return }
            if let data, let uiImage = UIImage(data: data) {
                ImageCache.shared.setObject(uiImage, forKey: key)
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            }
        }
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
