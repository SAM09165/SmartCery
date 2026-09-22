//
//  LoopingVideoPlayerView.swift
//  SmartCery
//
//  High-performance muted looping video player for promotional media banners.
//  Uses AVPlayerLayer with aspectFill and automatic background/foreground lifecycle management.
//  Gracefully falls back to high-resolution generated static images with subtle Ken Burns motion.
//

import SwiftUI
import AVFoundation

struct LoopingVideoPlayerView: View {
    let videoURL: URL?
    let localResourceName: String?
    let posterImageName: String?
    let fallbackImageName: String?
    var isPlaying: Bool = true
    var onPlaybackReady: (() -> Void)? = nil

    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?
    @State private var isReady: Bool = false
    @State private var hasFailed: Bool = false
    @State private var kenBurnsZoom: Bool = false

    var body: some View {
        ZStack {
            // LAYER 1: POSTER / STATIC IMAGE WITH SUBTLE KEN BURNS MOTION
            if let poster = posterImageName ?? fallbackImageName {
                Image(poster)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(kenBurnsZoom ? 1.05 : 1.0)
                    .animation(
                        .easeInOut(duration: 8.0).repeatForever(autoreverses: true),
                        value: kenBurnsZoom
                    )
                    .onAppear {
                        kenBurnsZoom = true
                    }
            }

            // LAYER 2: HARDWARE-ACCELERATED AVPLAYER VIDEO LAYER
            if let player, !hasFailed {
                PlayerLayerView(player: player)
                    .opacity(isReady ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.5), value: isReady)
            }
        }
        .clipped()
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            tearDownPlayer()
        }
        .onChange(of: videoURL) { _, _ in
            setupPlayer()
        }
        .onChange(of: isPlaying) { _, playing in
            if playing {
                player?.play()
            } else {
                player?.pause()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            player?.pause()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if isPlaying {
                player?.play()
            }
        }
    }

    private func setupPlayer() {
        tearDownPlayer()

        // 1. Resolve effective URL (Local Bundle resource takes precedence if present)
        var targetURL: URL? = nil
        if let localName = localResourceName,
           let path = Bundle.main.url(forResource: localName, withExtension: "mp4") {
            targetURL = path
        } else if let remoteURL = videoURL {
            targetURL = remoteURL
        }

        // If no video URL or local file exists, rely cleanly on the high-res poster image
        guard let url = targetURL else {
            isReady = false
            hasFailed = false
            return
        }

        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)

        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.isMuted = true
        queuePlayer.actionAtItemEnd = .none

        let playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)

        self.player = queuePlayer
        self.looper = playerLooper
        self.hasFailed = false

        // Observe player item status
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            // AVPlayerLooper handles continuous loop automatically
        }

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            self.hasFailed = true
            self.isReady = false
        }

        // Observe player readiness
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemNewAccessLogEntry,
            object: playerItem,
            queue: .main
        ) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                self.isReady = true
            }
            self.onPlaybackReady?()
        }

        // Quick fallback check to ensure opacity fades in even if access log doesn't fire immediately
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if !self.isReady && self.player?.status != .failed && self.player?.currentItem?.status == .readyToPlay {
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.isReady = true
                }
                self.onPlaybackReady?()
            }
        }

        if isPlaying {
            queuePlayer.play()
        }
    }

    private func tearDownPlayer() {
        player?.pause()
        player?.removeAllItems()
        player = nil
        looper = nil
        isReady = false
        hasFailed = false
    }
}

// MARK: - UIKit Bridge for AVPlayerLayer
private struct PlayerLayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }
}

private final class PlayerUIView: UIView {
    override static var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
}
