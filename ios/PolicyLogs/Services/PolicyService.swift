import Foundation
import SwiftUI

@MainActor
class PolicyService: ObservableObject {
    @Published var logs: [PolicyLog] = []
    @Published var tags: [Tag] = []
    @Published var isLoading = false
    @Published var hasError = false
    @Published var errorMessage = ""
    
    private let apiService = APIService.shared
    private var currentPage = 1
    private var hasMorePages = true
    
    init() {
        // Load mock data for development
        loadMockData()
    }
    
    // MARK: - Policy Logs
    
    func fetchLogs(refresh: Bool = false) async throws {
        guard !isLoading else { return }
        
        isLoading = true
        hasError = false
        
        if refresh {
            currentPage = 1
            hasMorePages = true
        }
        
        do {
            let response = try await apiService.fetchLogs(page: currentPage)
            
            if refresh {
                logs = response.results
            } else {
                logs.append(contentsOf: response.results)
            }
            
            currentPage += 1
            hasMorePages = response.next != nil
            
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
            
            // If API fails, keep using mock data for development
            if logs.isEmpty {
                loadMockData()
            }
            
            print("Failed to fetch logs: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchLog(id: Int) async throws -> PolicyLog {
        return try await apiService.fetchLog(id: id)
    }
    
    func createLog(
        title: String,
        description: String,
        status: String = "pending",
        tagIds: [Int] = []
    ) async throws -> PolicyLog {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let newLog = try await apiService.createLog(
                title: title,
                description: description,
                status: status,
                tagIds: tagIds
            )
            
            // Add to local array
            logs.insert(newLog, at: 0)
            
            return newLog
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func addComment(to logId: Int, content: String) async throws -> LogComment {
        return try await apiService.addComment(to: logId, content: content)
    }
    
    func fetchMyLogs() async throws -> [PolicyLog] {
        do {
            let response = try await apiService.fetchMyLogs()
            return response.results
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func loadMoreLogs() async {
        guard hasMorePages && !isLoading else { return }
        
        do {
            try await fetchLogs(refresh: false)
        } catch {
            print("Failed to load more logs: \(error)")
        }
    }
    
    // MARK: - Tags
    
    func fetchTags() async throws {
        do {
            tags = try await apiService.fetchTags()
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
            print("Failed to fetch tags: \(error)")
        }
    }
    
    // MARK: - Search
    
    func searchLogs(_ query: String) async throws -> [PolicyLog] {
        do {
            let response = try await apiService.fetchLogs(page: 1, search: query)
            return response.results
        } catch {
            hasError = true
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadMockData() {
        logs = PolicyLog.mockData
    }
    
    func refreshData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    try await self.fetchLogs(refresh: true)
                } catch {
                    print("Failed to refresh logs: \(error)")
                }
            }
            
            group.addTask {
                do {
                    try await self.fetchTags()
                } catch {
                    print("Failed to refresh tags: \(error)")
                }
            }
        }
    }
}