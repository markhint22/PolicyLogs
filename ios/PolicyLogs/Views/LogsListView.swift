import SwiftUI

struct LogsListView: View {
    @EnvironmentObject var policyService: PolicyService
    @State private var searchText = ""
    @State private var isLoading = false
    
    var filteredLogs: [PolicyLog] {
        if searchText.isEmpty {
            return policyService.logs
        } else {
            return policyService.logs.filter { log in
                log.title.localizedCaseInsensitiveContains(searchText) ||
                log.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredLogs) { log in
                    NavigationLink(destination: LogDetailView(log: log)) {
                        LogRowView(log: log)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search logs...")
            .refreshable {
                await loadLogs()
            }
            .navigationTitle("Policy Logs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        // TODO: Implement add log functionality
                    }
                }
            }
        }
        .onAppear {
            Task {
                await loadLogs()
            }
        }
    }
    
    private func loadLogs() async {
        isLoading = true
        do {
            try await policyService.fetchLogs()
        } catch {
            print("Error loading logs: \(error)")
        }
        isLoading = false
    }
}

struct LogRowView: View {
    let log: PolicyLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(log.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(log.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                StatusBadge(status: log.status)
                
                Spacer()
                
                Text(log.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: String
    
    var badgeColor: Color {
        switch status.lowercased() {
        case "active": return .green
        case "pending": return .orange
        case "inactive": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor.opacity(0.2))
            .foregroundColor(badgeColor)
            .cornerRadius(8)
    }
}

#Preview {
    LogsListView()
        .environmentObject(PolicyService())
}