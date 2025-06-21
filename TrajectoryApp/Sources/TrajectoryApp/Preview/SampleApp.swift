import SwiftUI

@main
struct SampleApp: App {
    init() {
        PreviewHelper.setupPreviewEnvironment()
    }
    
    var body: some Scene {
        WindowGroup {
            SampleContentView()
        }
    }
}

struct SampleContentView: View {
    @State private var selectedArticle: NewsArticle?
    @State private var showAnalysis = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Sample Articles")) {
                    ForEach(PreviewHelper.sampleArticles) { article in
                        ArticleRow(article: article)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedArticle = article
                                showAnalysis = true
                            }
                    }
                }
                
                Section(header: Text("About")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI Analysis Demo")
                            .font(.headline)
                        Text("This sample app demonstrates the AI analysis capabilities using Grok API. Select any article to view its analysis.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Trajectory Demo")
            .sheet(isPresented: $showAnalysis) {
                if let article = selectedArticle {
                    NavigationView {
                        ArticleAnalysisView(article: article)
                    }
                }
            }
        }
    }
}

struct ArticleRow: View {
    let article: NewsArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
            
            HStack {
                Text(article.author)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatDate(article.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(article.summary)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    SampleContentView()
}
