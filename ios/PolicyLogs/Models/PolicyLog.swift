import Foundation

struct PolicyLog: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
    let policyDocument: String?
    let createdByName: String
    let createdAt: Date
    let updatedAt: Date
    let status: String
    let tags: [Tag]
    let comments: [LogComment]
    let commentsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, status, tags, comments
        case policyDocument = "policy_document"
        case createdByName = "created_by_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case commentsCount = "comments_count"
    }
}

struct Tag: Identifiable, Codable {
    let id: Int
    let name: String
    let color: String
}

struct LogComment: Identifiable, Codable {
    let id: Int
    let content: String
    let authorName: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, content
        case authorName = "author_name"
        case createdAt = "created_at"
    }
}

// MARK: - Mock Data for Previews
extension PolicyLog {
    static let mockData: [PolicyLog] = [
        PolicyLog(
            id: 1,
            title: "Data Privacy Policy Update",
            description: "Updated our data privacy policy to comply with new regulations and improve user data protection.",
            policyDocument: nil,
            createdByName: "John Doe",
            createdAt: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            updatedAt: Date().addingTimeInterval(-86400),     // 1 day ago
            status: "active",
            tags: [
                Tag(id: 1, name: "Privacy", color: "#007bff"),
                Tag(id: 2, name: "Compliance", color: "#28a745")
            ],
            comments: [
                LogComment(
                    id: 1,
                    content: "This looks good. When will it go into effect?",
                    authorName: "Jane Smith",
                    createdAt: Date().addingTimeInterval(-3600) // 1 hour ago
                )
            ],
            commentsCount: 1
        ),
        PolicyLog(
            id: 2,
            title: "Remote Work Guidelines",
            description: "Establishing comprehensive guidelines for remote work arrangements, including security protocols and communication standards.",
            policyDocument: nil,
            createdByName: "Alice Johnson",
            createdAt: Date().addingTimeInterval(-86400 * 5), // 5 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 3), // 3 days ago
            status: "pending",
            tags: [
                Tag(id: 3, name: "Remote Work", color: "#ffc107"),
                Tag(id: 4, name: "Security", color: "#dc3545")
            ],
            comments: [],
            commentsCount: 0
        ),
        PolicyLog(
            id: 3,
            title: "Code of Conduct Revision",
            description: "Annual review and revision of the company code of conduct to address new workplace scenarios and expectations.",
            policyDocument: nil,
            createdByName: "Bob Wilson",
            createdAt: Date().addingTimeInterval(-86400 * 7), // 7 days ago
            updatedAt: Date().addingTimeInterval(-86400 * 7), // 7 days ago
            status: "inactive",
            tags: [
                Tag(id: 5, name: "HR", color: "#6f42c1"),
                Tag(id: 6, name: "Ethics", color: "#20c997")
            ],
            comments: [
                LogComment(
                    id: 2,
                    content: "We should include guidelines for social media usage.",
                    authorName: "Carol Brown",
                    createdAt: Date().addingTimeInterval(-86400 * 2) // 2 days ago
                ),
                LogComment(
                    id: 3,
                    content: "Agreed. Also need to address AI tool usage.",
                    authorName: "David Lee",
                    createdAt: Date().addingTimeInterval(-86400) // 1 day ago
                )
            ],
            commentsCount: 2
        )
    ]
}