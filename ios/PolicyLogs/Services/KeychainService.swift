import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    private let service = "PolicyLogsApp"
    private let tokenKey = "auth_token"
    private let userKey = "current_user"
    
    // MARK: - Token Management
    
    func saveToken(_ token: String) {
        let data = Data(token.utf8)
        save(data, for: tokenKey)
    }
    
    func getToken() -> String? {
        guard let data = load(for: tokenKey) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func deleteToken() {
        delete(for: tokenKey)
    }
    
    // MARK: - User Management
    
    func saveUser(_ user: User) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        save(data, for: userKey)
    }
    
    func getUser() -> User? {
        guard let data = load(for: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else { return nil }
        return user
    }
    
    func deleteUser() {
        delete(for: userKey)
    }
    
    // MARK: - Private Keychain Methods
    
    private func save(_ data: Data, for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Failed to save to keychain: \(status)")
        }
    }
    
    private func load(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            return nil
        }
        
        return result as? Data
    }
    
    private func delete(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Failed to delete from keychain: \(status)")
        }
    }
    
    // MARK: - Clear All Data
    
    func clearAll() {
        deleteToken()
        deleteUser()
    }
}