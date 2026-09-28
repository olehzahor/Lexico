//
//  TTSPlaybackServiceProtocol.swift
//  Lexico
//
//  Created by Codex on 2/17/26.
//

import Foundation

@MainActor
protocol TTSPlaybackServiceProtocol: AnyObject {
    func prepareWord(id: Int, deckID: String)
    func prepareSentence(id: Int, deckID: String)
    func playWord(id: Int, deckID: String)
    func playSentence(id: Int, deckID: String)
    func stop()
}
