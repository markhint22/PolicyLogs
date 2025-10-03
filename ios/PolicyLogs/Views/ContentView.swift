import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            authService.checkAuthenticationStatus()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            LogsListView()
                .tabItem {
                    Label("Logs", systemImage: "doc.text")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationService())
        .environmentObject(PolicyService())
}