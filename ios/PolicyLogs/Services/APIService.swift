import Foundation
import Alamofire

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:8000/api"
    private let session: Session
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = Session(configuration: configuration)
    }
    
    // MARK: - Private Methods
    
    private func makeRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: HTTPHeaders? = nil,
        responseType: T.Type
    ) async throws -> T {
        let url = "\(baseURL)\(endpoint)"
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private var authHeaders: HTTPHeaders? {
        guard let token = KeychainService.shared.getToken() else { return nil }
        return HTTPHeaders(["Authorization": "Token \(token)"])
    }
    
    // MARK: - Authentication
    
    func login(username: String, password: String) async throws -> LoginResponse {
        let parameters: Parameters = [
            "username": username,
            "password": password
        ]
        
        return try await makeRequest(
            endpoint: "/auth/login/",
            method: .post,
            parameters: parameters,
            responseType: LoginResponse.self
        )
    }
    
    func register(
        username: String,
        email: String,
        firstName: String,
        lastName: String,
        password: String
    ) async throws -> User {
        let parameters: Parameters = [
            "username": username,
            "email": email,
            "first_name": firstName,
            "last_name": lastName,
            "password": password,
            "password_confirm": password
        ]
        
        return try await makeRequest(
            endpoint: "/auth/register/",
            method: .post,
            parameters: parameters,
            responseType: User.self
        )
    }
    
    func logout() async throws {
        _ = try await makeRequest(
            endpoint: "/auth/logout/",
            method: .post,
            headers: authHeaders,
            responseType: EmptyResponse.self
        )
    }
    
    func getProfile() async throws -> UserProfile {
        return try await makeRequest(
            endpoint: "/auth/profile/",
            headers: authHeaders,
            responseType: UserProfile.self
        )
    }
    
    // MARK: - Policy Logs
    
    func fetchLogs(page: Int = 1, search: String? = nil) async throws -> PolicyLogsResponse {
        var parameters: Parameters = ["page": page]
        if let search = search, !search.isEmpty {
            parameters["search"] = search
        }
        
        return try await makeRequest(
            endpoint: "/policy-logs/",
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: authHeaders,
            responseType: PolicyLogsResponse.self
        )
    }
    
    func fetchLog(id: Int) async throws -> PolicyLog {
        return try await makeRequest(
            endpoint: "/policy-logs/\(id)/",
            headers: authHeaders,
            responseType: PolicyLog.self
        )
    }
    
    func createLog(
        title: String,
        description: String,
        status: String = "pending",
        tagIds: [Int] = []
    ) async throws -> PolicyLog {
        let parameters: Parameters = [
            "title": title,
            "description": description,
            "status": status,
            "tag_ids": tagIds
        ]
        
        return try await makeRequest(
            endpoint: "/policy-logs/",
            method: .post,
            parameters: parameters,
            headers: authHeaders,
            responseType: PolicyLog.self
        )
    }
    
    func addComment(to logId: Int, content: String) async throws -> LogComment {
        let parameters: Parameters = ["content": content]
        
        return try await makeRequest(
            endpoint: "/policy-logs/\(logId)/add_comment/",
            method: .post,
            parameters: parameters,
            headers: authHeaders,
            responseType: LogComment.self
        )
    }
    
    func fetchMyLogs() async throws -> PolicyLogsResponse {
        return try await makeRequest(
            endpoint: "/policy-logs/my_logs/",
            headers: authHeaders,
            responseType: PolicyLogsResponse.self
        )
    }
    
    // MARK: - Tags
    
    func fetchTags() async throws -> [Tag] {
        return try await makeRequest(
            endpoint: "/tags/",
            headers: authHeaders,
            responseType: [Tag].self
        )
    }
}

// MARK: - Response Models

struct PolicyLogsResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PolicyLog]
}

struct EmptyResponse: Codable {
    // Empty response for endpoints that don't return data
}