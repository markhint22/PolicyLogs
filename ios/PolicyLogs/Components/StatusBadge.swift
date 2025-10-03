import SwiftUI

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.2))
            .foregroundColor(textColor)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch status.lowercased() {
        case "draft":
            return Color.gray
        case "pending":
            return Color.orange
        case "active":
            return Color.green
        case "inactive":
            return Color.red
        case "archived":
            return Color.purple
        default:
            return Color.blue
        }
    }
    
    private var textColor: Color {
        switch status.lowercased() {
        case "draft":
            return Color.gray
        case "pending":
            return Color.orange
        case "active":
            return Color.green
        case "inactive":
            return Color.red
        case "archived":
            return Color.purple
        default:
            return Color.blue
        }
    }
}

#Preview {
    VStack {
        StatusBadge(status: "draft")
        StatusBadge(status: "pending")
        StatusBadge(status: "active")
        StatusBadge(status: "inactive")
        StatusBadge(status: "archived")
    }
}