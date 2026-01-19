import AVFoundation
import SwiftUI

#if os(iOS)
import UIKit
#else
import AppKit
#endif

@available(iOS 17.0, macOS 11.0, *)
struct LoopingVideoView: View {
    let url: URL

    var body: some View {
        LoopingVideoRepresentable(url: url)
    }
}

#if os(iOS)
@available(iOS 17.0, macOS 11.0, *)
private struct LoopingVideoRepresentable: UIViewRepresentable {
    let url: URL

    final class Coordinator {
        let player: AVQueuePlayer
        let looper: AVPlayerLooper

        init(url: URL) {
            let item = AVPlayerItem(url: url)
            let player = AVQueuePlayer()
            self.player = player
            self.looper = AVPlayerLooper(player: player, templateItem: item)
        }
    }

    final class PlayerContainerView: UIView {
        let playerLayer: AVPlayerLayer

        override init(frame: CGRect) {
            self.playerLayer = AVPlayerLayer()
            super.init(frame: frame)
            layer.addSublayer(playerLayer)
            playerLayer.videoGravity = .resizeAspectFill
        }

        required init?(coder: NSCoder) {
            return nil
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            playerLayer.frame = bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.playerLayer.player = context.coordinator.player
        context.coordinator.player.play()
        context.coordinator.player.isMuted = true
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        uiView.playerLayer.player = context.coordinator.player
        context.coordinator.player.play()
    }

    static func dismantleUIView(_ uiView: PlayerContainerView, coordinator: Coordinator) {
        coordinator.player.pause()
    }
}
#else
@available(iOS 17.0, macOS 11.0, *)
private struct LoopingVideoRepresentable: NSViewRepresentable {
    let url: URL

    final class Coordinator {
        let player: AVQueuePlayer
        let looper: AVPlayerLooper

        init(url: URL) {
            let item = AVPlayerItem(url: url)
            let player = AVQueuePlayer()
            self.player = player
            self.looper = AVPlayerLooper(player: player, templateItem: item)
        }
    }

    final class PlayerContainerView: NSView {
        let playerLayer: AVPlayerLayer

        override init(frame frameRect: NSRect) {
            self.playerLayer = AVPlayerLayer()
            super.init(frame: frameRect)
            wantsLayer = true
            layer?.addSublayer(playerLayer)
            playerLayer.videoGravity = .resizeAspectFill
        }

        required init?(coder: NSCoder) {
            return nil
        }

        override func layout() {
            super.layout()
            playerLayer.frame = bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    func makeNSView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.playerLayer.player = context.coordinator.player
        context.coordinator.player.play()
        context.coordinator.player.isMuted = true
        return view
    }

    func updateNSView(_ nsView: PlayerContainerView, context: Context) {
        nsView.playerLayer.player = context.coordinator.player
        context.coordinator.player.play()
    }

    static func dismantleNSView(_ nsView: PlayerContainerView, coordinator: Coordinator) {
        coordinator.player.pause()
    }
}
#endif
