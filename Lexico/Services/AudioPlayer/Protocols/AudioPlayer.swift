//
//  AudioPlayer.swift
//  Lexico
//
//  Created by Codex on 2/17/26.
//

import Foundation

@MainActor
protocol AudioPlayer: AnyObject {
    func play(url: URL)
    func stop()
}
