//
//  TTSAudioPlayer.swift
//  Lexico
//
//  Created by Codex on 2/17/26.
//

import AVFoundation
import Foundation

@MainActor
final class TTSAudioPlayer: AudioPlayer {
    static let shared = TTSAudioPlayer()

    private let player: AVPlayer
    private let fileCache: AudioFileCache
    private let itemCache: AudioPlayerItemCache
    private var isAudioSessionConfigured = false
    private var playbackRequestID = UUID()

    func prepare(url: URL) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let localURL = try await fileCache.fileURL(for: url)
                itemCache.prepare(url: localURL, makeItem: makeItem)
            } catch {
                // Playback retries the download if preparation fails.
            }
        }
    }

    func play(url: URL) {
        playbackRequestID = UUID()
        let requestID = playbackRequestID
        player.pause()
        player.replaceCurrentItem(with: nil)

        Task { [weak self] in
            guard let self else { return }
            do {
                let localURL = try await fileCache.fileURL(for: url)
                guard playbackRequestID == requestID else { return }

                let item = itemCache.item(for: localURL, makeItem: makeItem)
                guard try await item.asset.load(.isPlayable) else { return }
                guard playbackRequestID == requestID else { return }

                configureAudioSessionIfNeeded()
                player.replaceCurrentItem(with: item)
                player.automaticallyWaitsToMinimizeStalling = true

                let seekCompleted: Bool = await withCheckedContinuation { continuation in
                    player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { completed in
                        continuation.resume(returning: completed)
                    }
                }
                guard seekCompleted, playbackRequestID == requestID else { return }

                player.play()
            } catch {
                // A later tap can retry the request.
            }
        }
    }

    func stop() {
        playbackRequestID = UUID()
        player.pause()
        player.replaceCurrentItem(with: nil)
    }

    private func configureAudioSessionIfNeeded() {
        guard !isAudioSessionConfigured else { return }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
            try audioSession.setActive(true)
            isAudioSessionConfigured = true
        } catch {
            // TODO: Add logs
        }
    }

    private func makeItem(url: URL) -> AVPlayerItem {
        AVPlayerItem(url: url)
    }

    private init(player: AVPlayer = AVPlayer()) {
        self.player = player
        self.fileCache = AudioFileCache()
        self.itemCache = AudioPlayerItemCache(maxItems: 50)
    }
}
