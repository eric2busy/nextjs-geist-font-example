import SwiftUI

struct ReadingListView: View {
    @EnvironmentObject private var articleRepository: ArticleRepository
    @EnvironmentObject private var sessionManager: SessionManager
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            Group {
                if articleRepository.isLoading {
                    ProgressView("Loading saved articles...")
                } else if articleRepository.savedArticles.isEmpty {
                    EmptyReadingListView()
                } else {
                    List {
                        ForEach(articleRepository.savedArticles) { article in
                            NavigationLink(destination: ArticleDetailView(article: article)) {
                                SavedArticleRow(article: article)
                            }
                        }
                        .onDelete { offsets in
                            Task {
                                for index in offsets {
                                    if let userId = sessionManager.currentUser?.id {
                                        await articleRepository.unsaveArticle(articleRepository.savedArticles[index], userId: userId)
                                    }
                                }
                            }
                        }
                    }
                    .refreshable {
                        if let userId = sessionManager.currentUser?.id {
                            await articleRepository.fetchSavedArticles(userId: userId)
                        }
                    }
                }
            }
            .navigationTitle("Reading List")
            .alert("Error", isPresented: $showError) {
                Button("OK") {
                    articleRepository.clearError()
                }
            } message: {
                Text(articleRepository.error?.localizedDescription ?? "An unknown error occurred")
            }
            .onAppear {
                Task {
                    if let userId = sessionManager.currentUser?.id {
                        await articleRepository.fetchSavedArticles(userId: userId)
                    }
                }
            }
            .onChange(of: articleRepository.error) { error in
                showError = error != nil
            }
        }
    }
}

struct SavedArticleRow: View {
    let article: NewsArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
            
            HStack {
                Text(article.sourceName)
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                Text(formatDate(article.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(article.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct EmptyReadingListView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.circle")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("No Saved Articles")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Articles you save will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct ReadingListView_Previews: PreviewProvider {
    static var previews: some View {
        ReadingListView()
    }
}
