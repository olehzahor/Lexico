//
//  R2MediaURLProvider.swift
//  Lexico
//
//  Created by Codex on 2/17/26.
//

import CryptoKit
import Foundation

final class R2MediaURLProvider: MediaURLProvider {
    private let endpointURL: URL?
    private let bucket: String
    private let accessKeyID: String
    private let secretAccessKey: String
    private let expiresInSeconds: Int
    private let nowProvider: () -> Date

    init(
        baseURLString: String = LocalSecrets.r2PublicBaseURL,
        bucket: String = LocalSecrets.r2Bucket,
        accessKeyID: String = LocalSecrets.r2AccessKeyID,
        secretAccessKey: String = LocalSecrets.r2SecretAccessKey,
        expiresInSeconds: Int = 3600,
        nowProvider: @escaping () -> Date = Date.init
    ) {
        guard let endpointURL = URL(string: baseURLString) else {
            self.endpointURL = nil
            self.bucket = ""
            self.accessKeyID = ""
            self.secretAccessKey = ""
            self.expiresInSeconds = expiresInSeconds
            self.nowProvider = nowProvider
            return
        }

        self.endpointURL = endpointURL
        self.bucket = bucket.trimmingCharacters(in: .whitespacesAndNewlines)
        self.accessKeyID = accessKeyID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.secretAccessKey = secretAccessKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.expiresInSeconds = expiresInSeconds
        self.nowProvider = nowProvider
    }

    func wordURL(for id: Int) -> URL? {
        mediaURL(directory: "word", id: id, fileExtension: "m4a")
    }

    func sentenceURL(for id: Int) -> URL? {
        mediaURL(directory: "sentences", id: id, fileExtension: "m4a")
    }

    private func mediaURL(directory: String, id: Int, fileExtension: String) -> URL? {
        guard
            id > 0,
            let endpointURL,
            bucket.isEmpty == false,
            accessKeyID.isEmpty == false,
            secretAccessKey.isEmpty == false
        else {
            return nil
        }

        let objectKey = "\(directory)/\(id).\(fileExtension)"
        let canonicalURI = "/\(bucket)/\(objectKey)"
        let host = endpointURL.host() ?? ""
        guard host.isEmpty == false else { return nil }

        let now = nowProvider()
        let amzDate = Self.amzDateFormatter.string(from: now)
        let shortDate = Self.shortDateFormatter.string(from: now)
        let credentialScope = "\(shortDate)/auto/s3/aws4_request"
        let signedHeaders = "host"

        var queryItems: [(String, String)] = [
            ("X-Amz-Algorithm", "AWS4-HMAC-SHA256"),
            ("X-Amz-Credential", "\(accessKeyID)/\(credentialScope)"),
            ("X-Amz-Date", amzDate),
            ("X-Amz-Expires", "\(expiresInSeconds)"),
            ("X-Amz-SignedHeaders", signedHeaders)
        ]

        let canonicalQuery = Self.canonicalQueryString(from: queryItems)
        let canonicalHeaders = "host:\(host)\n"
        let canonicalRequest = [
            "GET",
            canonicalURI,
            canonicalQuery,
            canonicalHeaders,
            signedHeaders,
            "UNSIGNED-PAYLOAD"
        ].joined(separator: "\n")

        let hashedCanonicalRequest = Self.sha256Hex(canonicalRequest)
        let stringToSign = [
            "AWS4-HMAC-SHA256",
            amzDate,
            credentialScope,
            hashedCanonicalRequest
        ].joined(separator: "\n")

        let signingKey = Self.signingKey(
            secretAccessKey: secretAccessKey,
            shortDate: shortDate,
            region: "auto",
            service: "s3"
        )
        let signature = Self.hmacHex(stringToSign, key: signingKey)
        queryItems.append(("X-Amz-Signature", signature))

        let finalQuery = Self.canonicalQueryString(from: queryItems)
        var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false)
        components?.percentEncodedPath = canonicalURI
        components?.percentEncodedQuery = finalQuery
        return components?.url
    }
}

private extension R2MediaURLProvider {
    static let amzDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return formatter
    }()

    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()

    static func canonicalQueryString(from items: [(String, String)]) -> String {
        items
            .map { (percentEncode($0.0), percentEncode($0.1)) }
            .sorted { lhs, rhs in
                if lhs.0 != rhs.0 { return lhs.0 < rhs.0 }
                return lhs.1 < rhs.1
            }
            .map { "\($0)=\($1)" }
            .joined(separator: "&")
    }

    static func percentEncode(_ string: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? string
    }

    static func sha256Hex(_ string: String) -> String {
        let digest = SHA256.hash(data: Data(string.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func hmacHex(_ string: String, key: SymmetricKey) -> String {
        let signature = HMAC<SHA256>.authenticationCode(for: Data(string.utf8), using: key)
        return signature.map { String(format: "%02x", $0) }.joined()
    }

    static func hmacData(_ data: Data, key: SymmetricKey) -> Data {
        let code = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return Data(code)
    }

    static func signingKey(secretAccessKey: String, shortDate: String, region: String, service: String) -> SymmetricKey {
        let kSecret = SymmetricKey(data: Data(("AWS4" + secretAccessKey).utf8))
        let kDate = SymmetricKey(data: hmacData(Data(shortDate.utf8), key: kSecret))
        let kRegion = SymmetricKey(data: hmacData(Data(region.utf8), key: kDate))
        let kService = SymmetricKey(data: hmacData(Data(service.utf8), key: kRegion))
        let kSigning = hmacData(Data("aws4_request".utf8), key: kService)
        return SymmetricKey(data: kSigning)
    }
}
