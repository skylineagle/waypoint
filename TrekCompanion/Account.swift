import Foundation
import Security

struct Account: Codable {
    var serverURL: URL
    var email: String
    var password: String
    var token: String
    var trip: Trip?

    private static let keychainQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: "trek-account",
    ]

    static func load() -> Account? {
        var query = keychainQuery
        query[kSecReturnData as String] = true
        var result: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return try? JSONDecoder().decode(Account.self, from: data)
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        Self.delete()
        var query = Self.keychainQuery
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(query as CFDictionary, nil)
    }

    static func delete() {
        SecItemDelete(keychainQuery as CFDictionary)
    }
}
