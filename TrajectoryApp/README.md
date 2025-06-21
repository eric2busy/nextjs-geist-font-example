# Trajectory App Demo

A demo application showcasing AI-powered news article analysis using the Grok API. This demo demonstrates bias detection, AI summaries, and story trajectory analysis.

## Features

- **Bias Analysis**: Detect and visualize potential bias in articles
- **AI Summaries**: Get concise, AI-generated summaries of articles
- **Story Trajectory**: Track how stories evolve over time
- **Related Articles**: Find connections between different articles

## Prerequisites

- Xcode 15.0 or later
- Swift 5.9 or later
- A Grok API key

## Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd TrajectoryApp
```

2. Configure your Grok API key:
   - Copy `Config.xcconfig.template` to `Config.xcconfig`
   - Add your Grok API key:
```
GROK_API_KEY = your-api-key-here
GROK_MAX_TOKENS = 2000
```

3. Build the project:
```bash
swift build
```

## Running the Demo

There are two ways to run the demo:

### 1. Command Line

```bash
swift run TrajectoryDemo
```

### 2. Xcode

1. Open the project in Xcode:
```bash
xed .
```
2. Select the "TrajectoryDemo" scheme
3. Click Run (⌘R)

## Using the Demo

1. **Browse Sample Articles**
   - The demo includes sample articles about AI technology
   - Each article demonstrates different aspects of the analysis

2. **View Article Analysis**
   - Tap any article to see its analysis
   - The analysis view includes:
     * Bias detection with confidence score
     * AI-generated summary
     * Story trajectory (for related articles)
     * Related articles suggestions

3. **Bias Analysis**
   - The bias indicator shows:
     * Left-leaning (blue)
     * Neutral (green)
     * Right-leaning (red)
   - Includes confidence score and reasoning

4. **Story Trajectory**
   - Shows how stories evolve over time
   - Highlights key developments
   - Identifies perspective shifts

## Architecture

The demo uses:
- SwiftUI for the user interface
- Grok API for AI analysis
- MVVM architecture pattern
- Async/await for API calls

Key components:
- `GrokService`: Handles AI analysis API calls
- `ArticleAnalysisView`: Displays analysis results
- `PreviewHelper`: Provides sample data
- `SampleApp`: Demo app entry point

## Testing Different Scenarios

1. **Single Article Analysis**
   - Select any individual article
   - View its bias analysis and AI summary

2. **Story Trajectory**
   - The sample articles form a story sequence
   - View how the AI tracks story evolution

3. **Related Articles**
   - See how the AI finds connections between articles
   - Understand different perspectives on the same topic

## Customization

You can modify the sample articles in `PreviewHelper.swift` to test different scenarios:
- Change article content
- Add more articles
- Modify article relationships

## Troubleshooting

1. **API Key Issues**
   - Ensure your Grok API key is correctly set in Config.xcconfig
   - Check the API key has necessary permissions

2. **Build Issues**
   - Make sure you have the latest Xcode and Swift
   - Try cleaning the build folder: `swift package clean`

3. **Runtime Issues**
   - Check console for error messages
   - Verify network connectivity
   - Ensure API rate limits haven't been exceeded

## Contributing

Feel free to:
- Submit bug reports
- Propose new features
- Send pull requests

## License

This demo is provided for educational purposes. See LICENSE file for details.
