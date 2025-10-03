import Foundation
import SwiftUI

@MainActor
class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    
    private let apiService = APIService.shared
    private let keychainService = KeychainService.shared
    
    init() {
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        currentUser = keychainService.getUser()
        isAuthenticated = (keychainService.getToken() != nil && currentUser != nil)
    }
    
    func login(username: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await apiService.login(username: username, password: password)
            
            // Save token and user to keychain
            keychainService.saveToken(response.token)
            keychainService.saveUser(response.user)
            
            // Update UI state
            currentUser = response.user
            isAuthenticated = true
            
        } catch {
            throw AuthenticationError.loginFailed(error.localizedDescription)
        }
    }
    
    func register(
        username: String,
        email: String,
        firstName: String,
        lastName: String,
        password: String
    ) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await apiService.register(
                username: username,
                email: email,
                firstName: firstName,
                lastName: lastName,
                password: password
            )
            
            // After successful registration, attempt to login
            try await login(username: username, password: password)
            
        } catch {
            throw AuthenticationError.registrationFailed(error.localizedDescription)
        }
    }
    
    func logout() {
        Task {
            do {
                try await apiService.logout()
            } catch {
                print("Logout API call failed: \(error)")
                // Continue with local logout even if API call fails
            }
            
            await MainActor.run {
                performLocalLogout()
            }
        }
    }
    
    private func performLocalLogout() {
        keychainService.clearAll()
        currentUser = nil
        isAuthenticated = false
    }
    
    func refreshUserProfile() async {
        guard isAuthenticated else { return }
        
        do {
            let profile = try await apiService.getProfile()
            currentUser = profile.user
            keychainService.saveUser(profile.user)
        } catch {
            print("Failed to refresh user profile: \(error)")
        }
    }
}

// MARK: - Authentication Errors

enum AuthenticationError: LocalizedError {
    case loginFailed(String)
    case registrationFailed(String)
    case tokenExpired
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .loginFailed(let message):
            return "Login failed: \(message)"
        case .registrationFailed(let message):
            return "Registration failed: \(message)"
        case .tokenExpired:
            return "Your session has expired. Please log in again."
        case .networkError:
            return "Network error. Please check your connection and try again."
        }
    }
}