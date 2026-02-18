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
    private let itemCache: AudioPlayerItemCache
    private var isAudioSessionConfigured = false

    func prepare(url: URL) {
        configureAudioSessionIfNeeded()
        itemCache.prepare(url: url, makeItem: makeItem)
    }

    func play(url: URL) {
        configureAudioSessionIfNeeded()

        let item = itemCache.item(for: url, makeItem: makeItem)
        if player.currentItem !== item {
            player.replaceCurrentItem(with: item)
        }

        if shouldRestartFromBeginning(item) {
            item.seek(to: .zero, completionHandler: nil)
        }

        player.automaticallyWaitsToMinimizeStalling = false
        player.playImmediately(atRate: 1.0)
    }

    func stop() {
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
        let item = AVPlayerItem(url: url)
        item.preferredForwardBufferDuration = 0
        return item
    }

    private func shouldRestartFromBeginning(_ item: AVPlayerItem) -> Bool {
        let durationSeconds = item.duration.seconds
        guard durationSeconds.isFinite, durationSeconds > 0 else { return false }
        return item.currentTime().seconds >= (durationSeconds - 0.05)
    }

    private init(player: AVPlayer = AVPlayer()) {
        self.player = player
        self.itemCache = AudioPlayerItemCache(maxItems: 50)
    }
}
