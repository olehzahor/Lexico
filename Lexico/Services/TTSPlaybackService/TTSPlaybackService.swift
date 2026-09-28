//
//  TTSPlaybackService.swift
//  Lexico
//
//  Created by Codex on 2/17/26.
//

import Foundation

@MainActor
final class TTSPlaybackService: TTSPlaybackServiceProtocol {
    static let shared = TTSPlaybackService()

    private let mediaURLProvider: any MediaURLProvider
    private let audioPlayer: any AudioPlayer

    func prepareWord(id: Int, deckID: String) {
        guard let url = mediaURLProvider.wordURL(for: id, deckID: deckID) else { return }
        audioPlayer.prepare(url: url)
    }

    func prepareSentence(id: Int, deckID: String) {
        guard let url = mediaURLProvider.sentenceURL(for: id, deckID: deckID) else { return }
        audioPlayer.prepare(url: url)
    }

    func playWord(id: Int, deckID: String) {
        guard let url = mediaURLProvider.wordURL(for: id, deckID: deckID) else { return }
        audioPlayer.play(url: url)
    }

    func playSentence(id: Int, deckID: String) {
        guard let url = mediaURLProvider.sentenceURL(for: id, deckID: deckID) else { return }
        audioPlayer.play(url: url)
    }

    func stop() {
        audioPlayer.stop()
    }
    
    init(
        mediaURLProvider: any MediaURLProvider,
        audioPlayer: any AudioPlayer
    ) {
        self.mediaURLProvider = mediaURLProvider
        self.audioPlayer = audioPlayer
    }

    convenience init() {
        self.init(
            mediaURLProvider: R2MediaURLProvider(),
            audioPlayer: TTSAudioPlayer.shared
        )
    }
}
