import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NewsFeedView()
                .tabItem {
                    Label("Discover", systemImage: "newspaper")
                }
            ReadingListView()
                .tabItem {
                    Label("Reading List", systemImage: "bookmark")
                }
            AccountSettingsView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
