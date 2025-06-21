import SwiftUI

@main
struct TrajectoryApp: App {
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var articleRepository = ArticleRepository()

    var body: some Scene {
        WindowGroup {
            if sessionManager.isAuthenticated {
                MainTabView()
                    .environmentObject(sessionManager)
                    .environmentObject(articleRepository)
            } else {
                SignInView()
                    .environmentObject(sessionManager)
            }
        }
    }
}
