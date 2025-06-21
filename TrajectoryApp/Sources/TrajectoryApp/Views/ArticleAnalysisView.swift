import SwiftUI

struct ArticleAnalysisView: View {
    let article: NewsArticle
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Bias Analysis
                biasSection
                
                Divider()
                
                // AI Summary
                summarySection
                
                Divider()
                
                // Story Trajectory
                trajectorySection
            }
            .padding()
        }
        .navigationTitle("AI Analysis")
        .task {
            await viewModel.analyzeArticle(article)
        }
    }
    
    private var biasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bias Analysis")
                .font(.headline)
            
            if let bias = viewModel.bias {
                // Bias Level Indicator
                VStack(alignment: .leading, spacing: 8) {
                    Text("Bias Level")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 8)
                            
                            // Bias indicator
                            RoundedRectangle(cornerRadius: 4)
                                .fill(biasColor(level: bias.biasLevel))
                                .frame(width: geometry.size.width * CGFloat((bias.biasLevel + 1) / 2), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    // Labels
                    HStack {
                        Text("Left")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Neutral")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Confidence
                Text("Confidence: \(Int(bias.confidence * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Reasoning
                Text("Analysis")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(bias.reasoning)
                    .font(.body)
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Summary")
                .font(.headline)
            
            if let summary = viewModel.summary {
                Text(summary)
                    .font(.body)
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var trajectorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Story Trajectory")
                .font(.headline)
            
            if let trajectory = viewModel.trajectory {
                VStack(alignment: .leading, spacing: 16) {
                    // Key Developments
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Key Developments")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ForEach(trajectory.evolution, id: \.self) { development in
                            HStack(alignment: .top, spacing: 8) {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 8, height: 8)
                                    .padding(.top, 6)
                                
                                Text(development)
                                    .font(.body)
                            }
                        }
                    }
                    
                    // Perspective Shifts
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Perspective Shifts")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ForEach(trajectory.perspectiveShifts, id: \.self) { shift in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond")
                                    .foregroundColor(.purple)
                                    .font(.system(size: 12))
                                    .padding(.top, 4)
                                
                                Text(shift)
                                    .font(.body)
                            }
                        }
                    }
                    
                    // Confidence
                    Text("Analysis Confidence: \(Int(trajectory.confidence * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
            }
        }
    }
    
    private func biasColor(level: Double) -> Color {
        let normalized = (level + 1) / 2 // Convert from [-1, 1] to [0, 1]
        
        if abs(level) < 0.1 { // Near neutral
            return .green
        } else if level < 0 { // Left-leaning
            return .blue.opacity(Double.maximum(0.3, abs(level)))
        } else { // Right-leaning
            return .red.opacity(Double.maximum(0.3, level))
        }
    }
}

// MARK: - ViewModel

extension ArticleAnalysisView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published private(set) var bias: GrokService.ArticleBias?
        @Published private(set) var summary: String?
        @Published private(set) var trajectory: GrokService.StoryTrajectory?
        @Published private(set) var isLoading = false
        @Published private(set) var error: String?
        
        func analyzeArticle(_ article: NewsArticle) async {
            isLoading = true
            error = nil
            
            do {
                async let biasTask = GrokService.shared.analyzeBias(article)
                async let summaryTask = GrokService.shared.generateSummary(article)
                async let trajectoryTask = GrokService.shared.analyzeTrajectory([article])
                
                let (bias, summary, trajectory) = try await (biasTask, summaryTask, trajectoryTask)
                
                self.bias = bias
                self.summary = summary
                self.trajectory = trajectory
            } catch {
                self.error = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}

#Preview {
    NavigationView {
        ArticleAnalysisView(article: PreviewHelper.sampleArticle)
            .onAppear {
                PreviewHelper.setupPreviewEnvironment()
            }
    }
}

struct ArticleAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Single Article Analysis
            NavigationView {
                ArticleAnalysisView(article: PreviewHelper.sampleArticle)
            }
            .previewDisplayName("Single Article")
            
            // Story Trajectory Analysis
            NavigationView {
                ArticleAnalysisView(article: PreviewHelper.sampleArticles[0])
            }
            .previewDisplayName("Story Trajectory")
        }
        .onAppear {
            PreviewHelper.setupPreviewEnvironment()
        }
    }
}
