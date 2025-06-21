import SwiftUI

struct AccountSettingsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showingSignOutAlert = false
    @State private var notificationsEnabled = true
    @State private var selectedTheme = "System"
    @State private var textSize = 1.0
    
    let themes = ["System", "Light", "Dark"]
    
    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    HStack {
                        Text("Signed in with Apple")
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    Button(role: .destructive) {
                        showingSignOutAlert = true
                    } label: {
                        Text("Sign Out")
                    }
                }
                
                Section("Preferences") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(themes, id: \.self) { theme in
                            Text(theme)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Text Size")
                        Slider(value: $textSize, in: 0.8...1.2, step: 0.1) {
                            Text("Text Size")
                        }
                    }
                }
                
                Section("Reading List") {
                    NavigationLink("Manage Categories") {
                        ManageCategoriesView()
                    }
                    
                    NavigationLink("Export Reading List") {
                        ExportReadingListView()
                    }
                }
                
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://trajectory.app/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://trajectory.app/terms")!)
                    NavigationLink("About Trajectory") {
                        AboutView()
                    }
                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Account")
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        try? await sessionManager.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

// Placeholder views for navigation destinations
struct ManageCategoriesView: View {
    var body: some View {
        Text("Manage Categories")
            .navigationTitle("Categories")
    }
}

struct ExportReadingListView: View {
    var body: some View {
        Text("Export Reading List")
            .navigationTitle("Export")
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "newspaper.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("Trajectory")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your personalized news companion that helps you understand different perspectives and track the evolution of stories over time.")
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .navigationTitle("About")
        .padding()
    }
}

struct AccountSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingsView()
            .environmentObject(SessionManager())
    }
}
