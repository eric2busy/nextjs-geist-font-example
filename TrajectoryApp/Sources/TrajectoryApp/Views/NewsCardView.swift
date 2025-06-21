import SwiftUI

struct NewsCardView: View {
    let article: NewsArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Article image if available
            if let imageUrl = article.imageUrl {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Article metadata
            HStack {
                Text(article.sourceName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                Text(formatDate(article.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Article title
            Text(article.title)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(2)
            
            // Article summary
            Text(article.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Category tag
            Text(article.category)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.1))
                .foregroundColor(.accentColor)
                .clipShape(Capsule())
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct NewsCardView_Previews: PreviewProvider {
    static var previews: some View {
        NewsCardView(article: NewsArticle(
            title: "Sample Article Title",
            category: "Technology",
            date: Date(),
            author: "John Doe",
            imageUrl: nil,
            summary: "This is a sample article summary that demonstrates how the card will look with actual content.",
            sourceName: "Tech News",
            sourceUrl: URL(string: "https://example.com")!
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
