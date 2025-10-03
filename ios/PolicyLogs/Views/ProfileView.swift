import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingLogout = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text(authService.currentUser?.username ?? "Unknown User")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            if let email = authService.currentUser?.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Account") {
                    NavigationLink(destination: EditProfileView()) {
                        HStack {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("Edit Profile")
                        }
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Image(systemName: "gear")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("Settings")
                        }
                    }
                }
                
                Section("Data") {
                    NavigationLink(destination: MyLogsView()) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("My Logs")
                        }
                    }
                }
                
                Section {
                    Button(action: { showingLogout = true }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 20)
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Sign Out", isPresented: $showingLogout) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authService.logout()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var bio = ""
    @State private var department = ""
    @State private var phoneNumber = ""
    @State private var isLoading = false
    
    var body: some View {
        Form {
            Section("Basic Information") {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Section("Additional Information") {
                TextField("Department", text: $department)
                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                
                TextField("Bio", text: $bio, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            Section {
                Button("Save Changes") {
                    saveProfile()
                }
                .disabled(isLoading)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadProfileData()
        }
    }
    
    private func loadProfileData() {
        // Load current user data
        if let user = authService.currentUser {
            firstName = user.firstName ?? ""
            lastName = user.lastName ?? ""
            email = user.email ?? ""
        }
        
        // TODO: Load additional profile data from API
    }
    
    private func saveProfile() {
        isLoading = true
        
        // TODO: Implement API call to save profile
        
        Task {
            // Simulate API call
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var biometricEnabled = false
    
    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Push Notifications", isOn: $notificationsEnabled)
            }
            
            Section("Security") {
                Toggle("Biometric Authentication", isOn: $biometricEnabled)
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MyLogsView: View {
    @EnvironmentObject var policyService: PolicyService
    @State private var myLogs: [PolicyLog] = []
    @State private var isLoading = false
    
    var body: some View {
        List {
            ForEach(myLogs) { log in
                NavigationLink(destination: LogDetailView(log: log)) {
                    LogRowView(log: log)
                }
            }
        }
        .navigationTitle("My Logs")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await loadMyLogs()
        }
        .onAppear {
            Task {
                await loadMyLogs()
            }
        }
    }
    
    private func loadMyLogs() async {
        isLoading = true
        
        // TODO: Implement API call to fetch user's logs
        // For now, filter from all logs
        myLogs = policyService.logs // This should be filtered by current user
        
        isLoading = false
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationService())
}