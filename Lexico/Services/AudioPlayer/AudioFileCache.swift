//
//  AudioFileCache.swift
//  Lexico
//
//  Created by Codex on 9/30/26.
//

import CryptoKit
import Foundation

actor AudioFileCache {
    private struct Entry {
        let size: Int64
        var previous: String?
        var next: String?
    }

    private enum CacheError: Error {
        case invalidResponse
        case unsuccessfulResponse
        case emptyFile
        case fileExceedsLimit
    }

    private let maximumSize: Int64 = 100_000_000 // 100 MB
    private let cacheDirectory: URL
    private let fileManager: FileManager
    private let session: URLSession

    private var entries: [String: Entry] = [:]
    private var leastRecentlyUsed: String?
    private var mostRecentlyUsed: String?
    private var cachedSize: Int64 = 0
    private var indexLoaded = false
    private var downloads: [String: Task<URL, Error>] = [:]

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        self.cacheDirectory = cachesDirectory.appendingPathComponent("AudioFiles", isDirectory: true)

        let configuration = URLSessionConfiguration.ephemeral
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: configuration)
    }

    func fileURL(for remoteURL: URL) async throws -> URL {
        try loadIndexIfNeeded()

        let filename = Self.cacheFilename(for: remoteURL)
        let localURL = cacheDirectory.appendingPathComponent(filename)
        if let entry = entries[filename],
           fileManager.fileExists(atPath: localURL.path),
           let attributes = try? fileManager.attributesOfItem(atPath: localURL.path),
           let size = attributes[.size] as? NSNumber,
           size.int64Value == entry.size,
           size.int64Value > 0 {
            touch(filename)
            return localURL
        }

        if entries[filename] != nil {
            try? fileManager.removeItem(at: localURL)
            removeEntry(filename)
        }

        if fileManager.fileExists(atPath: localURL.path) {
            try? fileManager.removeItem(at: localURL)
        }

        if let download = downloads[filename] {
            return try await download.value
        }

        let download = Task { try await self.download(remoteURL, to: localURL, filename: filename) }
        downloads[filename] = download
        defer { downloads[filename] = nil }
        return try await download.value
    }

    private func download(_ remoteURL: URL, to localURL: URL, filename: String) async throws -> URL {
        let (temporaryURL, response) = try await session.download(from: remoteURL)
        defer { try? fileManager.removeItem(at: temporaryURL) }

        guard let response = response as? HTTPURLResponse else {
            throw CacheError.invalidResponse
        }
        guard (200..<300).contains(response.statusCode) else {
            throw CacheError.unsuccessfulResponse
        }

        let attributes = try fileManager.attributesOfItem(atPath: temporaryURL.path)
        guard let number = attributes[.size] as? NSNumber, number.int64Value > 0 else {
            throw CacheError.emptyFile
        }
        let fileSize = number.int64Value
        guard fileSize <= maximumSize else {
            throw CacheError.fileExceedsLimit
        }

        try evictFilesIfNeeded(for: fileSize)
        try fileManager.moveItem(at: temporaryURL, to: localURL)
        appendAsMostRecent(filename, size: fileSize)
        return localURL
    }

    private func loadIndexIfNeeded() throws {
        guard !indexLoaded else { return }
        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        let keys: Set<URLResourceKey> = [.isRegularFileKey, .fileSizeKey, .contentModificationDateKey]
        let files = try fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsHiddenFiles]
        )

        let existingEntries = files.compactMap { url -> (String, Int64, Date)? in
            guard url.pathExtension == "m4a",
                  let values = try? url.resourceValues(forKeys: keys),
                  values.isRegularFile == true,
                  let size = values.fileSize,
                  size > 0 else {
                return nil
            }
            return (url.lastPathComponent, Int64(size), values.contentModificationDate ?? .distantPast)
        }

        for (filename, size, _) in existingEntries.sorted(by: { $0.2 < $1.2 }) {
            appendAsMostRecent(filename, size: size)
        }
        indexLoaded = true
        try evictFilesIfNeeded(for: 0)
    }

    private func evictFilesIfNeeded(for incomingSize: Int64) throws {
        while cachedSize + incomingSize > maximumSize {
            guard let oldest = leastRecentlyUsed else { break }
            let url = cacheDirectory.appendingPathComponent(oldest)
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }
            removeEntry(oldest)
        }
    }

    private func touch(_ filename: String) {
        guard entries[filename] != nil else { return }
        moveToMostRecent(filename)
        let url = cacheDirectory.appendingPathComponent(filename)
        try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: url.path)
    }

    private func appendAsMostRecent(_ filename: String, size: Int64) {
        entries[filename] = Entry(size: size, previous: mostRecentlyUsed, next: nil)
        if let mostRecentlyUsed {
            entries[mostRecentlyUsed]?.next = filename
        } else {
            leastRecentlyUsed = filename
        }
        mostRecentlyUsed = filename
        cachedSize += size
    }

    private func moveToMostRecent(_ filename: String) {
        guard filename != mostRecentlyUsed, let entry = entries[filename] else { return }

        if let previous = entry.previous {
            entries[previous]?.next = entry.next
        } else {
            leastRecentlyUsed = entry.next
        }
        if let next = entry.next {
            entries[next]?.previous = entry.previous
        }

        entries[filename]?.previous = mostRecentlyUsed
        entries[filename]?.next = nil
        if let mostRecentlyUsed {
            entries[mostRecentlyUsed]?.next = filename
        }
        mostRecentlyUsed = filename
    }

    private func removeEntry(_ filename: String) {
        guard let entry = entries.removeValue(forKey: filename) else { return }

        if let previous = entry.previous {
            entries[previous]?.next = entry.next
        } else {
            leastRecentlyUsed = entry.next
        }
        if let next = entry.next {
            entries[next]?.previous = entry.previous
        } else {
            mostRecentlyUsed = entry.previous
        }
        cachedSize -= entry.size
    }

    private static func cacheFilename(for url: URL) -> String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        // The signature query changes over time; the R2 object path stays the same.
        components?.query = nil
        components?.fragment = nil
        let stableURL = components?.string ?? url.absoluteString
        let digest = SHA256.hash(data: Data(stableURL.utf8))
        let name = digest.map { String(format: "%02x", $0) }.joined()
        let fileExtension = url.pathExtension.lowercased()
        return fileExtension.isEmpty ? name : "\(name).\(fileExtension)"
    }
}
