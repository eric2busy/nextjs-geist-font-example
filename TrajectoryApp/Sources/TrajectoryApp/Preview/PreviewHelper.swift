import Foundation

enum PreviewHelper {
    static let sampleArticle = NewsArticle(
        title: "AI Breakthrough: New Model Shows Human-Like Understanding",
        category: "Technology",
        date: Date(),
        author: "Sarah Chen",
        imageUrl: URL(string: "https://example.com/ai-image.jpg"),
        summary: """
        Researchers at a leading AI lab have developed a new language model that demonstrates unprecedented levels of contextual understanding and reasoning abilities. The model, trained on a diverse dataset of scientific literature and human interactions, has shown remarkable capabilities in understanding nuanced queries and providing detailed, accurate responses.
        
        Initial tests reveal that the model can engage in complex problem-solving tasks and even understand subtle humor and sarcasm - abilities that have long been considered uniquely human. This breakthrough could have significant implications for fields ranging from healthcare to education.
        
        However, experts caution that while the advancement is significant, more research is needed to fully understand the model's limitations and potential biases. The development team emphasizes their commitment to ethical AI development and transparent testing procedures.
        """,
        sourceName: "Tech Insights Daily",
        sourceUrl: URL(string: "https://techinsights.example.com/ai-breakthrough")!
    )
    
    static let sampleArticles = [
        sampleArticle,
        NewsArticle(
            title: "AI Ethics Board Raises Concerns Over New Model",
            category: "Technology",
            date: Date().addingTimeInterval(86400), // Next day
            author: "Michael Roberts",
            imageUrl: URL(string: "https://example.com/ai-ethics.jpg"),
            summary: """
            Following yesterday's announcement of a breakthrough in AI language understanding, the International AI Ethics Board has raised important questions about the technology's implications. The board emphasizes the need for careful consideration of privacy concerns and potential misuse.
            
            Key concerns include data privacy, algorithmic bias, and the potential for automated misinformation. The ethics board has called for additional independent testing and greater transparency in the development process.
            
            The AI lab behind the breakthrough has welcomed the scrutiny and agreed to work closely with ethics experts to address these concerns.
            """,
            sourceName: "Tech Insights Daily",
            sourceUrl: URL(string: "https://techinsights.example.com/ai-ethics-concerns")!
        ),
        NewsArticle(
            title: "Industry Leaders Respond to AI Breakthrough",
            category: "Technology",
            date: Date().addingTimeInterval(172800), // Two days later
            author: "David Kim",
            imageUrl: URL(string: "https://example.com/industry-response.jpg"),
            summary: """
            Major tech companies and industry leaders have begun responding to this week's AI breakthrough in language understanding. Several companies have announced plans to integrate similar technologies into their products, while others express skepticism about the claimed capabilities.
            
            Market analysts predict significant impacts on various sectors, from customer service to content creation. However, implementation timelines remain unclear as companies navigate technical and ethical considerations.
            
            Meanwhile, smaller AI firms are expressing concerns about the concentration of advanced AI capabilities among a few major players.
            """,
            sourceName: "Tech Insights Daily",
            sourceUrl: URL(string: "https://techinsights.example.com/industry-response")!
        )
    ]
}

#if DEBUG
extension PreviewHelper {
    static func setupPreviewEnvironment() {
        // Set up any necessary environment variables or configurations for preview
        UserDefaults.standard.set("preview_mode", forKey: "environment")
    }
}
#endif
