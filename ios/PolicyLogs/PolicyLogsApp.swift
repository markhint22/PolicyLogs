import SwiftUI

@main
struct PolicyLogsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthenticationService())
                .environmentObject(PolicyService())
        }
    }
}