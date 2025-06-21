import SwiftUI
import AVFoundation

struct ArticleDetailView: View {
    let article: NewsArticle
    
    @EnvironmentObject private var articleRepository: ArticleRepository
    @EnvironmentObject private var sessionManager: SessionManager
    @State private var isSpeaking = false
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var showTrajectorySheet = false
    @State private var showAnalysisSheet = false
    @State private var showError = false
    
    private var isAddedToReadingList: Bool {
        articleRepository.savedArticles.contains(article)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header image
                if let imageUrl = article.imageUrl {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Article metadata
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(article.sourceName)
                            .font(.headline)
                            .foregroundColor(.accentColor)
                        
                        Spacer()
                        
                        // Source bias indicator
                        SourceBiasView(bias: .neutral) // TODO: Implement bias calculation
                    }
                    
                    Text(article.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("By \(article.author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(formatDate(article.date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Action buttons
                HStack(spacing: 20) {
                    Button(action: toggleSpeech) {
                        Label(isSpeaking ? "Stop" : "Listen", systemImage: isSpeaking ? "stop.fill" : "play.fill")
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { showTrajectorySheet = true }) {
                        Label("Trajectory", systemImage: "arrow.triangle.branch")
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: toggleReadingList) {
                        Label(isAddedToReadingList ? "Saved" : "Save", 
                              systemImage: isAddedToReadingList ? "bookmark.fill" : "bookmark")
                    }
                    .buttonStyle(.bordered)
                }
                
                // Article summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Summary")
                        .font(.headline)
                    
                    Text(article.summary)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Divider()
                
                // Full article content would go here
                // TODO: Implement full article content display
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $showTrajectorySheet) {
            TrajectoryView(article: article)
        }
        .sheet(isPresented: $showAnalysisSheet) {
            ArticleAnalysisView(article: article)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                articleRepository.clearError()
            }
        } message: {
            Text(articleRepository.error?.localizedDescription ?? "An unknown error occurred")
        }
        .onChange(of: articleRepository.error) { error in
            showError = error != nil
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: toggleReadingList) {
                    Image(systemName: isAddedToReadingList ? "bookmark.fill" : "bookmark")
                }
                
                Button(action: { showAnalysisSheet = true }) {
                    Image(systemName: "brain")
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    private func toggleSpeech() {
        if isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        } else {
            let utterance = AVSpeechUtterance(string: article.summary)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synthesizer.speak(utterance)
        }
        isSpeaking.toggle()
    }
    
    private func toggleReadingList() {
        guard let userId = sessionManager.currentUser?.id else { return }
        
        Task {
            if isAddedToReadingList {
                await articleRepository.unsaveArticle(article, userId: userId)
            } else {
                await articleRepository.saveArticle(article, userId: userId)
            }
        }
    }
}

extension ArticleDetailView {
    var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleReadingList) {
                    Image(systemName: isAddedToReadingList ? "bookmark.fill" : "bookmark")
                }
            }
        }
    }
}

struct SourceBiasView: View {
    enum Bias {
        case left, neutral, right
        
        var color: Color {
            switch self {
            case .left: return .blue
            case .neutral: return .green
            case .right: return .red
            }
        }
    }
    
    let bias: Bias
    
    var body: some View {
        HStack(spacing: 4) {
            Text("Bias:")
                .font(.caption)
            Circle()
                .fill(bias.color)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Placeholder for TrajectoryView
struct TrajectoryView: View {
    let article: NewsArticle
    
    var body: some View {
        Text("Trajectory View - Coming Soon")
            .padding()
    }
}

struct ArticleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleDetailView(article: NewsArticle(
            title: "Sample Article",
            category: "Technology",
            date: Date(),
            author: "John Doe",
            imageUrl: nil,
            summary: "This is a sample article summary for preview purposes.",
            sourceName: "Tech News",
            sourceUrl: URL(string: "https://example.com")!
        ))
    }
}
