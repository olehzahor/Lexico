//
//  AudioPlayerItemCache.swift
//  Lexico
//
//  Created by Codex on 2/17/26.
//

import AVFoundation
import Foundation

@MainActor
final class AudioPlayerItemCache {
    private let maxItems: Int
    private var items: [URL: AVPlayerItem] = [:]
    private var order: [URL] = []

    func prepare(url: URL, makeItem: (URL) -> AVPlayerItem) {
        _ = item(for: url, makeItem: makeItem)
    }

    func item(for url: URL, makeItem: (URL) -> AVPlayerItem) -> AVPlayerItem {
        if let existing = items[url] {
            touch(url)
            return existing
        }

        let newItem = makeItem(url)
        items[url] = newItem
        touch(url)
        evictIfNeeded()
        preload(newItem)
        return newItem
    }

    init(maxItems: Int = 50) {
        self.maxItems = maxItems
    }

    private func touch(_ url: URL) {
        if let index = order.firstIndex(of: url) {
            order.remove(at: index)
        }
        order.append(url)
    }

    private func evictIfNeeded() {
        while order.count > maxItems, let oldest = order.first {
            order.removeFirst()
            items.removeValue(forKey: oldest)
        }
    }

    private func preload(_ item: AVPlayerItem) {
        Task { [item] in
            _ = try? await item.asset.load(.isPlayable)
        }
    }
}
