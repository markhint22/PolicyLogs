import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let username: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let dateJoined: Date
    
    enum CodingKeys: String, CodingKey {
        case id, username, email
        case firstName = "first_name"
        case lastName = "last_name"
        case dateJoined = "date_joined"
    }
}

struct UserProfile: Codable {
    let user: User
    let avatar: String?
    let bio: String?
    let phoneNumber: String?
    let department: String?
    
    enum CodingKeys: String, CodingKey {
        case user, avatar, bio, department
        case phoneNumber = "phone_number"
    }
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let user: User
}

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let password: String
    let passwordConfirm: String
    
    enum CodingKeys: String, CodingKey {
        case username, email, password
        case firstName = "first_name"
        case lastName = "last_name"
        case passwordConfirm = "password_confirm"
    }
}