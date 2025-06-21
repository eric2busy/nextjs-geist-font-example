import Foundation

actor GrokService {
    static let shared = GrokService()
    
    private let apiKey: String
    private let baseURL = URL(string: "https://api.grok.ai/v1")!
    
    private init() {
        self.apiKey = try! GrokConfig.apiKey
    }
    
    // MARK: - Article Analysis
    
    func analyzeBias(_ article: NewsArticle) async throws -> ArticleBias {
        let prompt = """
        Analyze the following article for potential bias. Consider:
        1. Language and tone
        2. Source credibility
        3. Fact presentation
        4. Balance of viewpoints
        
        Title: \(article.title)
        Author: \(article.author)
        Source: \(article.sourceName)
        Content: \(article.summary)
        
        Provide a JSON response with:
        - bias_level: (number between -1 and 1, where -1 is extremely left-leaning, 0 is neutral, 1 is extremely right-leaning)
        - confidence: (number between 0 and 1)
        - reasoning: (string explaining the analysis)
        """
        
        let response = try await sendRequest(
            endpoint: "chat/completions",
            body: ChatRequest(prompt: prompt, responseFormat: .json)
        )
        
        return try JSONDecoder().decode(ArticleBias.self, from: response)
    }
    
    func generateSummary(_ article: NewsArticle) async throws -> String {
        let prompt = """
        Summarize the following article in a concise, informative manner:
        
        Title: \(article.title)
        Author: \(article.author)
        Content: \(article.summary)
        
        Provide a 2-3 sentence summary that captures the key points and main message.
        """
        
        let response = try await sendRequest(
            endpoint: "chat/completions",
            body: ChatRequest(prompt: prompt, responseFormat: .text)
        )
        
        return try JSONDecoder().decode(TextResponse.self, from: response).text
    }
    
    func findRelatedArticles(_ article: NewsArticle, candidates: [NewsArticle]) async throws -> [(NewsArticle, Double)] {
        let prompt = """
        Compare the following article with each candidate article and rate their relatedness on a scale of 0 to 1,
        where 1 means directly related (same story/topic) and 0 means completely unrelated.
        
        Base article:
        Title: \(article.title)
        Summary: \(article.summary)
        
        \(candidates.enumerated().map { index, candidate in
            """
            Candidate \(index + 1):
            Title: \(candidate.title)
            Summary: \(candidate.summary)
            """
        }.joined(separator: "\n\n"))
        
        Provide a JSON array of scores, one for each candidate article.
        """
        
        let response = try await sendRequest(
            endpoint: "chat/completions",
            body: ChatRequest(prompt: prompt, responseFormat: .json)
        )
        
        let scores = try JSONDecoder().decode([Double].self, from: response)
        return Array(zip(candidates, scores))
    }
    
    func analyzeTrajectory(_ articles: [NewsArticle]) async throws -> StoryTrajectory {
        let prompt = """
        Analyze how this story has evolved across multiple articles. Consider:
        1. Key developments
        2. Changing perspectives
        3. New information
        4. Shifts in tone or focus
        
        Articles in chronological order:
        \(articles.enumerated().map { index, article in
            """
            Article \(index + 1):
            Date: \(article.date)
            Title: \(article.title)
            Summary: \(article.summary)
            """
        }.joined(separator: "\n\n"))
        
        Provide a JSON response with:
        - evolution: (array of key developments in chronological order)
        - perspective_shifts: (array of notable changes in how the story is being told)
        - confidence: (number between 0 and 1 indicating confidence in the analysis)
        """
        
        let response = try await sendRequest(
            endpoint: "chat/completions",
            body: ChatRequest(prompt: prompt, responseFormat: .json)
        )
        
        return try JSONDecoder().decode(StoryTrajectory.self, from: response)
    }
    
    // MARK: - Networking
    
    private func sendRequest(endpoint: String, body: ChatRequest) async throws -> Data {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GrokError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw GrokError.serverError(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
}

// MARK: - Models

extension GrokService {
    struct ChatRequest: Codable {
        let prompt: String
        let responseFormat: ResponseFormat
        let temperature: Double
        
        init(prompt: String, responseFormat: ResponseFormat, temperature: Double = 0.3) {
            self.prompt = prompt
            self.responseFormat = responseFormat
            self.temperature = temperature
        }
        
        enum ResponseFormat: String, Codable {
            case text
            case json
            
            var mimeType: String {
                switch self {
                case .text: return "text/plain"
                case .json: return "application/json"
                }
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case prompt
            case responseFormat = "response_format"
            case temperature
        }
    }
    
    struct TextResponse: Codable {
        let text: String
    }
    
    struct ArticleBias: Codable {
        let biasLevel: Double
        let confidence: Double
        let reasoning: String
        
        enum CodingKeys: String, CodingKey {
            case biasLevel = "bias_level"
            case confidence
            case reasoning
        }
    }
    
    struct StoryTrajectory: Codable {
        let evolution: [String]
        let perspectiveShifts: [String]
        let confidence: Double
        
        enum CodingKeys: String, CodingKey {
            case evolution
            case perspectiveShifts = "perspective_shifts"
            case confidence
        }
    }
    
    enum GrokError: LocalizedError {
        case invalidResponse
        case serverError(statusCode: Int)
        
        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid response from server"
            case .serverError(let statusCode):
                return "Server error: \(statusCode)"
            }
        }
    }
}
