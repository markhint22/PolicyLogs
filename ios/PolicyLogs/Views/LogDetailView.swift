import SwiftUI

struct LogDetailView: View {
    let log: PolicyLog
    @State private var comments: [LogComment] = []
    @State private var newCommentText = ""
    @State private var isAddingComment = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section
                VStack(alignment: .leading, spacing: 12) {
                    Text(log.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        StatusBadge(status: log.status)
                        Spacer()
                        Text("Created: \(log.createdAt, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !log.createdByName.isEmpty {
                        Text("By: \(log.createdByName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Description section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    
                    Text(log.description)
                        .font(.body)
                }
                .padding(.horizontal)
                
                // Tags section
                if !log.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(log.tags, id: \.id) { tag in
                                    TagView(tag: tag)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Divider()
                
                // Comments section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Comments")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(comments.count)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    // Add comment section
                    VStack(spacing: 8) {
                        TextField("Add a comment...", text: $newCommentText, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                        
                        HStack {
                            Spacer()
                            Button("Add Comment") {
                                addComment()
                            }
                            .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAddingComment)
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    
                    // Comments list
                    ForEach(comments, id: \.id) { comment in
                        CommentView(comment: comment)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadComments()
        }
    }
    
    private func addComment() {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isAddingComment = true
        
        // TODO: Implement API call to add comment
        // For now, just add locally
        let newComment = LogComment(
            id: UUID().hashValue,
            content: newCommentText,
            authorName: "Current User", // TODO: Get from auth service
            createdAt: Date()
        )
        
        comments.append(newComment)
        newCommentText = ""
        isAddingComment = false
    }
    
    private func loadComments() {
        // TODO: Load comments from API
        // For now, use mock data
        comments = log.comments
    }
}

struct TagView: View {
    let tag: Tag
    
    var body: some View {
        Text(tag.name)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: tag.color)?.opacity(0.2) ?? Color.blue.opacity(0.2))
            .foregroundColor(Color(hex: tag.color) ?? .blue)
            .cornerRadius(8)
    }
}

struct CommentView: View {
    let comment: LogComment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(comment.authorName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(comment.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(comment.content)
                .font(.body)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// Extension to handle hex color strings
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

#Preview {
    NavigationView {
        LogDetailView(log: PolicyLog.mockData[0])
    }
}