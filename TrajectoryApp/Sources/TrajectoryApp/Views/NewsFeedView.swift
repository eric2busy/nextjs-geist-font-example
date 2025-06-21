import SwiftUI

struct NewsFeedView: View {
    @EnvironmentObject private var articleRepository: ArticleRepository
    @State private var selectedCategory: String = "All"
    @State private var categories: [String] = []
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            Group {
                if articleRepository.isLoading && articleRepository.articles.isEmpty {
                    ProgressView("Loading articles...")
                } else {
                    VStack(spacing: 0) {
                        // Category selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                        Task {
                                            await articleRepository.fetchArticles(category: category, refresh: true)
                                        }
                                    }) {
                                Text(category)
                                    .fontWeight(selectedCategory == category ? .bold : .regular)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedCategory == category ?
                                            Color.accentColor.opacity(0.1) :
                                            Color.clear
                                    )
                                    .clipShape(Capsule())
                            }
                            .foregroundColor(selectedCategory == category ? .accentColor : .gray)
                        }
                    }
                    .padding()
                }
                
                        // News feed
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(articleRepository.articles) { article in
                                    NavigationLink(destination: ArticleDetailView(article: article)) {
                                        NewsCardView(article: article)
                                    }
                                }
                                
                                if !articleRepository.articles.isEmpty {
                                    ProgressView()
                                        .padding()
                                        .onAppear {
                                            Task {
                                                await articleRepository.fetchArticles(category: selectedCategory)
                                            }
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Discover")
            .alert("Error", isPresented: $showError) {
                Button("OK") {
                    articleRepository.clearError()
                }
            } message: {
                Text(articleRepository.error?.localizedDescription ?? "An unknown error occurred")
            }
            .onAppear {
                Task {
                    await loadCategories()
                    await articleRepository.fetchArticles(refresh: true)
                }
            }
            .onChange(of: articleRepository.error) { error in
                showError = error != nil
            }
        }
    }
    
    private func loadCategories() async {
        categories = await articleRepository.fetchCategories()
    }
}

struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NewsFeedView()
    }
}
