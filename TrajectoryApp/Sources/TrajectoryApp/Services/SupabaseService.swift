import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    private let client: SupabaseClient
    
    private init() {
        do {
            let supabaseURL = try SupabaseConfig.projectURL
            let supabaseKey = try SupabaseConfig.anonKey
            
            var options = SupabaseClientOptions()
            options.realtime.enabled = (try? SupabaseConfig.realtimeEnabled) ?? false
            
            self.client = SupabaseClient(
                supabaseURL: supabaseURL,
                supabaseKey: supabaseKey,
                options: options
            )
        } catch {
            fatalError("Failed to initialize Supabase client: \(error)")
        }
    }
    
    // MARK: - Authentication
    
    func signInWithApple(idToken: String, nonce: String) async throws -> User {
        let response = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: idToken,
                nonce: nonce
            )
        )
        return response.user
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    // MARK: - Articles
    
    func fetchArticles(category: String? = nil, page: Int = 1) async throws -> [NewsArticle] {
        var query = client.database
            .from("articles")
            .select()
            .order("date", ascending: false)
            .range(((page - 1) * 20), (page * 20) - 1)
        
        if let category = category, category != "All" {
            query = query.eq("category", value: category)
        }
        
        let response: [ArticleResponse] = try await query.execute().value
        return response.map { $0.toNewsArticle() }
    }
    
    func saveArticle(_ articleId: UUID, userId: String) async throws {
        try await client.database
            .from("saved_articles")
            .insert(SavedArticle(userId: userId, articleId: articleId))
            .execute()
    }
    
    func unsaveArticle(_ articleId: UUID, userId: String) async throws {
        try await client.database
            .from("saved_articles")
            .delete()
            .eq("user_id", value: userId)
            .eq("article_id", value: articleId)
            .execute()
    }
    
    func fetchSavedArticles(userId: String) async throws -> [NewsArticle] {
        let response: [ArticleResponse] = try await client.database
            .from("saved_articles")
            .select("""
                article_id,
                articles (
                    id,
                    title,
                    category,
                    date,
                    author,
                    image_url,
                    summary,
                    source_name,
                    source_url
                )
            """)
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response.map { $0.toNewsArticle() }
    }
    
    // MARK: - User Preferences
    
    func updateUserPreferences(_ preferences: UserPreferences, userId: String) async throws {
        try await client.database
            .from("user_preferences")
            .upsert(preferences)
            .eq("user_id", value: userId)
            .execute()
    }
    
    func fetchUserPreferences(userId: String) async throws -> UserPreferences {
        let response: [UserPreferences] = try await client.database
            .from("user_preferences")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return response.first ?? UserPreferences(userId: userId)
    }
}

// MARK: - Response Models

private struct ArticleResponse: Codable {
    let id: UUID
    let title: String
    let category: String
    let date: Date
    let author: String
    let imageUrl: URL?
    let summary: String
    let sourceName: String
    let sourceUrl: URL
    
    func toNewsArticle() -> NewsArticle {
        NewsArticle(
            title: title,
            category: category,
            date: date,
            author: author,
            imageUrl: imageUrl,
            summary: summary,
            sourceName: sourceName,
            sourceUrl: sourceUrl
        )
    }
}

private struct SavedArticle: Codable {
    let userId: String
    let articleId: UUID
    let createdAt: Date?
}

struct UserPreferences: Codable {
    let userId: String
    var notificationsEnabled: Bool = true
    var theme: String = "System"
    var textSize: Double = 1.0
    var selectedCategories: [String] = []
}
