import Foundation
import Combine

class ArticleRepository: ObservableObject {
    private let supabase = SupabaseService.shared
    
    @Published private(set) var articles: [NewsArticle] = []
    @Published private(set) var savedArticles: [NewsArticle] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private var currentPage = 1
    private var hasMorePages = true
    
    // MARK: - Article Feed
    
    func fetchArticles(category: String? = nil, refresh: Bool = false) async {
        if refresh {
            currentPage = 1
            hasMorePages = true
        }
        
        guard hasMorePages else { return }
        
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let newArticles = try await supabase.fetchArticles(category: category, page: currentPage)
            
            await MainActor.run {
                if refresh {
                    articles = newArticles
                } else {
                    articles.append(contentsOf: newArticles)
                }
                
                hasMorePages = !newArticles.isEmpty
                currentPage += 1
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
        }
    }
    
    // MARK: - Reading List
    
    func fetchSavedArticles(userId: String) async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        do {
            let articles = try await supabase.fetchSavedArticles(userId: userId)
            
            await MainActor.run {
                savedArticles = articles
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                isLoading = false
            }
        }
    }
    
    func saveArticle(_ article: NewsArticle, userId: String) async {
        do {
            try await supabase.saveArticle(article.id, userId: userId)
            
            await MainActor.run {
                if !savedArticles.contains(where: { $0.id == article.id }) {
                    savedArticles.insert(article, at: 0)
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func unsaveArticle(_ article: NewsArticle, userId: String) async {
        do {
            try await supabase.unsaveArticle(article.id, userId: userId)
            
            await MainActor.run {
                savedArticles.removeAll { $0.id == article.id }
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    // MARK: - Article Search
    
    func searchArticles(query: String) async -> [NewsArticle] {
        // TODO: Implement article search with Supabase full-text search
        return []
    }
    
    // MARK: - Article Categories
    
    func fetchCategories() async -> [String] {
        // TODO: Implement category fetching from Supabase
        return ["All", "Technology", "Business", "Science", "Politics"]
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        error = nil
    }
}

// MARK: - Error Types

extension ArticleRepository {
    enum ArticleError: LocalizedError {
        case fetchFailed
        case saveFailed
        case deleteFailed
        case searchFailed
        
        var errorDescription: String? {
            switch self {
            case .fetchFailed:
                return "Failed to fetch articles"
            case .saveFailed:
                return "Failed to save article"
            case .deleteFailed:
                return "Failed to remove article from reading list"
            case .searchFailed:
                return "Failed to search articles"
            }
        }
    }
}

// MARK: - Helper Extensions

extension NewsArticle: Identifiable {
    var id: UUID {
        // Generate a deterministic UUID based on the article's unique properties
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(sourceName)
        hasher.combine(date)
        let hash = hasher.finalize()
        return UUID(uuidString: String(format: "%08x-0000-0000-0000-%012x", hash & 0xFFFFFFFF, (hash >> 32) & 0xFFFFFFFFFFFF)) ?? UUID()
    }
}

extension NewsArticle: Equatable {
    static func == (lhs: NewsArticle, rhs: NewsArticle) -> Bool {
        lhs.id == rhs.id
    }
}
