import Foundation

struct NewsArticle: Identifiable, Codable {
    let id: UUID = UUID()
    let title: String
    let category: String
    let date: Date
    let author: String
    let imageUrl: URL?
    let summary: String
    let sourceName: String
    let sourceUrl: URL
}
