//
//  MediaURLProvider.swift
//  Lexico
//
//  Created by Codex on 2/17/26.
//

import Foundation

protocol MediaURLProvider: AnyObject {
    func wordURL(for id: Int, deckID: String) -> URL?
    func sentenceURL(for id: Int, deckID: String) -> URL?
}
