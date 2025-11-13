import SwiftUI
import UIKit
import ImageIO

@available(iOS 17.0, macOS 11.0, *)
struct AnimatedGIFView: UIViewRepresentable {
    let resourceName: String

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.image = UIImage.animatedGIF(named: resourceName)
        applyFadeMask(to: imageView)
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        // No-op, static animation
    }

    private func applyFadeMask(to imageView: UIImageView) {
        let maskLayer = CAGradientLayer()
        maskLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        maskLayer.locations = [0, 0.08, 0.92, 1]
        maskLayer.startPoint = CGPoint(x: 0.5, y: 0)
        maskLayer.endPoint = CGPoint(x: 0.5, y: 1)

        let horizontalMask = CAGradientLayer()
        horizontalMask.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        horizontalMask.locations = [0, 0.08, 0.92, 1]
        horizontalMask.startPoint = CGPoint(x: 0, y: 0.5)
        horizontalMask.endPoint = CGPoint(x: 1, y: 0.5)

        let combinedLayer = CALayer()
        combinedLayer.frame = imageView.bounds
        maskLayer.frame = combinedLayer.bounds
        horizontalMask.frame = combinedLayer.bounds
        combinedLayer.addSublayer(maskLayer)
        combinedLayer.addSublayer(horizontalMask)

        imageView.layer.mask = combinedLayer
        imageView.layer.masksToBounds = true
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
