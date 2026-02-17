//
//  TTSPlaybackServiceProtocol.swift
//  Lexico
//
//  Created by Codex on 2/17/26.
//

import Foundation

@MainActor
protocol TTSPlaybackServiceProtocol: AnyObject {
    func playWord(id: Int)
    func playSentence(id: Int)
    func stop()
}
