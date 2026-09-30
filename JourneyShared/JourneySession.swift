import CryptoKit
import Foundation
import Security

nonisolated struct JourneySession: Codable, Equatable {
    let serverURL: URL
    let email: String
    var token: String
    let tripID: Int?
    let tripTitle: String?

    var scope: String {
        SHA256.hash(data: Data("\(serverURL.absoluteString)|\(email.lowercased())".utf8))
            .map { String(format: "%02x", $0) }.joined()
    }

    private static var query: [String: Any] {
        var result: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "waypoint-journey-session",
        ]
        if let group = Bundle.main.object(forInfoDictionaryKey: "JourneyKeychainGroup") as? String {
            result[kSecAttrAccessGroup as String] = group
        }
        return result
    }

    static func load() -> Self? {
        var query = query
        query[kSecReturnData as String] = true
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return try? JSONDecoder().decode(Self.self, from: data)
    }

    func save() throws {
        let data = try JSONEncoder().encode(self)
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        var status = SecItemUpdate(Self.query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            status = SecItemAdd(Self.query.merging(attributes) { _, value in value } as CFDictionary, nil)
        }
        guard status == errSecSuccess else { throw JourneyError.message("Open Waypoint to finish setting up photo sharing.") }
    }

    static func clear() {
        SecItemDelete(query as CFDictionary)
    }

    static func renew(from response: HTTPURLResponse, for scope: String) {
        guard var current = load(), current.scope == scope, let url = response.url,
              let headers = response.allHeaderFields as? [String: String],
              let token = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
                .first(where: { $0.name == "trek_session" && !$0.value.isEmpty })?.value else { return }
        current.token = token
        try? current.save()
    }
}

nonisolated enum JourneyError: LocalizedError {
    case message(String)
    case signIn

    var errorDescription: String? {
        switch self {
        case .message(let message): message
        case .signIn: "Sign in to TREK in Waypoint to continue. Your photos are kept on this phone."
        }
    }
}
