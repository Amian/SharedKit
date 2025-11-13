import SwiftUI
import ImageIO

#if canImport(UIKit)
import UIKit

@available(iOS 17.0, *)
public struct AnimatedGIFView: UIViewRepresentable {
    public let resourceName: String

    public init(resourceName: String) {
        self.resourceName = resourceName
    }

    public func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.image = UIImage.animatedGIF(named: resourceName)
        return imageView
    }

    public func updateUIView(_ uiView: UIImageView, context: Context) {
        // No-op
    }
}

private extension UIImage {
    static func animatedGIF(named name: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return animatedGIF(data: data)
    }

    static func animatedGIF(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var duration: Double = 0

        for index in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(UIImage(cgImage: cgImage))
            }
            duration += frameDuration(at: index, source: source)
        }

        if duration == 0 {
            duration = Double(count) / 24.0
        }

        return UIImage.animatedImage(with: images, duration: duration)
    }

    static func frameDuration(at index: Int, source: CGImageSource) -> Double {
        let defaultDuration = 0.1
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifInfo = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return defaultDuration
        }

        if let unclamped = gifInfo[kCGImagePropertyGIFUnclampedDelayTime] as? Double, unclamped > 0 {
            return unclamped
        }

        if let delay = gifInfo[kCGImagePropertyGIFDelayTime] as? Double, delay > 0 {
            return delay
        }

        return defaultDuration
    }
}

#elseif canImport(AppKit)
import AppKit

@available(macOS 11.0, *)
public struct AnimatedGIFView: NSViewRepresentable {
    public let resourceName: String

    public init(resourceName: String) {
        self.resourceName = resourceName
    }

    public func makeNSView(context: Context) -> NSImageView {
        let view = NSImageView()
        view.imageScaling = .scaleProportionallyUpOrDown
        view.animates = true
        view.image = NSImage.animatedGIF(named: resourceName)
        return view
    }

    public func updateNSView(_ nsView: NSImageView, context: Context) {}
}

private extension NSImage {
    static func animatedGIF(named name: String) -> NSImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return NSImage(data: data)
    }
}

#endif
