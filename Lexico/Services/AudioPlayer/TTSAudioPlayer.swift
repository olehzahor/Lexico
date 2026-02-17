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
    private var isAudioSessionConfigured = false

    private init(player: AVPlayer = AVPlayer()) {
        self.player = player
    }

    func play(url: URL) {
        stop()
        configureAudioSessionIfNeeded()
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
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
}
