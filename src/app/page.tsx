"use client"

import { useState } from 'react'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from '@/components/ui/dialog'

interface Article {
  id: number
  title: string
  author: string
  date: string
  summary: string
  sourceName: string
}

interface Analysis {
  biasLevel: number
  confidence: number
  reasoning: string
  summary: string
  evolution: string[]
  perspectiveShifts: string[]
}

const sampleArticles: Article[] = [
  {
    id: 1,
    title: "AI Breakthrough: New Model Shows Human-Like Understanding",
    author: "Sarah Chen",
    date: "March 15, 2024",
    summary: "Researchers at a leading AI lab have developed a new language model that demonstrates unprecedented levels of contextual understanding and reasoning abilities. The model, trained on a diverse dataset of scientific literature and human interactions, has shown remarkable capabilities in understanding nuanced queries and providing detailed, accurate responses.",
    sourceName: "Tech Insights Daily"
  },
  {
    id: 2,
    title: "AI Ethics Board Raises Concerns Over New Model",
    author: "Michael Roberts",
    date: "March 16, 2024",
    summary: "Following yesterday's announcement of a breakthrough in AI language understanding, the International AI Ethics Board has raised important questions about the technology's implications. The board emphasizes the need for careful consideration of privacy concerns and potential misuse.",
    sourceName: "Tech Insights Daily"
  },
  {
    id: 3,
    title: "Industry Leaders Respond to AI Breakthrough",
    author: "David Kim",
    date: "March 17, 2024",
    summary: "Major tech companies and industry leaders have begun responding to this week's AI breakthrough in language understanding. Several companies have announced plans to integrate similar technologies into their products, while others express skepticism about the claimed capabilities.",
    sourceName: "Tech Insights Daily"
  }
]

export default function Home() {
  const [selectedArticle, setSelectedArticle] = useState<Article | null>(null)
  const [showAnalysis, setShowAnalysis] = useState(false)
  const [analysis, setAnalysis] = useState<Analysis | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [darkMode, setDarkMode] = useState(false)

  const analyzeArticle = async (article: Article) => {
    setLoading(true)
    setError(null)
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1500))
      
      // Simulate random error for demo purposes
      if (Math.random() < 0.2) {
        throw new Error("Failed to analyze article. Please try again.")
      }
      
      setAnalysis({
        biasLevel: 0.2,
        confidence: 0.85,
        reasoning: "The article presents a balanced view of the AI breakthrough, though there is slight optimism towards technological progress. The reporting includes multiple perspectives and cites specific examples.",
        summary: "A groundbreaking AI model demonstrates human-like understanding capabilities, showing promise in various applications while raising important ethical considerations.",
        evolution: [
          "Initial breakthrough announcement",
          "Ethics board review and concerns",
          "Industry response and implementation plans"
        ],
        perspectiveShifts: [
          "From technical achievement to ethical implications",
          "From theoretical potential to practical applications",
          "From unified excitement to diverse industry opinions"
        ]
      })
    } catch (err) {
      setError(err instanceof Error ? err.message : "An unexpected error occurred")
    } finally {
      setLoading(false)
    }
  }

  const handleArticleClick = (article: Article) => {
    console.log('Article clicked:', article.title)
    setSelectedArticle(article)
    setShowAnalysis(true)
    analyzeArticle(article)
  }

  const getBiasColor = (level: number) => {
    if (Math.abs(level) < 0.1) return 'bg-green-500'
    return level < 0 ? 'bg-blue-500' : 'bg-red-500'
  }

  const toggleDarkMode = () => {
    setDarkMode(!darkMode)
    document.documentElement.classList.toggle('dark')
  }

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault()
      const currentIndex = selectedArticle 
        ? sampleArticles.findIndex(a => a.id === selectedArticle.id)
        : -1
      
      let newIndex
      if (e.key === 'ArrowDown') {
        newIndex = currentIndex < sampleArticles.length - 1 ? currentIndex + 1 : 0
      } else {
        newIndex = currentIndex > 0 ? currentIndex - 1 : sampleArticles.length - 1
      }
      
      handleArticleClick(sampleArticles[newIndex])
    }
  }

  useEffect(() => {
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [selectedArticle])

  return (
    <main className={`container mx-auto py-8 px-4 ${darkMode ? 'dark' : ''}`}>
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold">Trajectory Demo</h1>
        <Button
          variant="outline"
          size="icon"
          onClick={toggleDarkMode}
          className="rounded-full"
          aria-label={darkMode ? 'Switch to light mode' : 'Switch to dark mode'}
        >
          {darkMode ? '🌞' : '🌙'}
        </Button>
      </div>
      
      <section className="space-y-6">
        <h2 className="text-xl font-semibold">Sample Articles</h2>
        <div className="grid gap-6">
          {sampleArticles.map(article => (
            <div key={article.id} className="w-full">
              <Card 
                className="w-full p-6 hover:shadow-lg transition-shadow cursor-pointer"
                onClick={() => handleArticleClick(article)}
                role="button"
                tabIndex={0}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault()
                    handleArticleClick(article)
                  }
                }}
              >
                <h3 className="text-lg font-semibold mb-2 text-left">{article.title}</h3>
                <div className="flex justify-between text-sm text-gray-500 mb-3">
                  <span>{article.author}</span>
                  <span>{article.date}</span>
                </div>
                <p className="text-gray-600 line-clamp-3 text-left">{article.summary}</p>
              </Card>
            </div>
          ))}
        </div>
      </section>

      <Dialog open={showAnalysis} onOpenChange={setShowAnalysis}>
        <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>AI Analysis</DialogTitle>
            <DialogDescription>
              AI-powered analysis of the article showing bias detection, summary, and story trajectory.
            </DialogDescription>
          </DialogHeader>
          
          {loading ? (
            <div className="flex justify-center items-center py-12">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900"></div>
            </div>
          ) : error ? (
            <div className="flex flex-col items-center py-12 text-center">
              <div className="text-red-500 mb-4">⚠️ {error}</div>
              <Button variant="outline" onClick={() => analyzeArticle(selectedArticle!)}>
                Try Again
              </Button>
            </div>
          ) : analysis ? (
            <div className="space-y-8">
              {/* Bias Analysis */}
              <div>
                <h3 className="font-semibold mb-4">Bias Analysis</h3>
                <div className="space-y-4">
                  <div>
                    <div className="text-sm text-gray-500 mb-2">Bias Level</div>
                    <div className="h-2 bg-gray-200 rounded-full">
                      <div 
                        className={`h-full rounded-full ${getBiasColor(analysis.biasLevel)}`}
                        style={{ width: `${(analysis.biasLevel + 1) * 50}%` }}
                      />
                    </div>
                    <div className="flex justify-between text-sm text-gray-500 mt-1">
                      <span>Left</span>
                      <span>Neutral</span>
                      <span>Right</span>
                    </div>
                  </div>
                  <div>
                    <div className="text-sm text-gray-500">Confidence: {Math.round(analysis.confidence * 100)}%</div>
                  </div>
                  <div>
                    <div className="text-sm text-gray-500">Analysis</div>
                    <p className="mt-1">{analysis.reasoning}</p>
                  </div>
                </div>
              </div>

              {/* AI Summary */}
              <div>
                <h3 className="font-semibold mb-4">AI Summary</h3>
                <p>{analysis.summary}</p>
              </div>

              {/* Story Trajectory */}
              <div>
                <h3 className="font-semibold mb-4">Story Trajectory</h3>
                <div className="space-y-6">
                  <div>
                    <h4 className="text-sm text-gray-500 mb-3">Key Developments</h4>
                    <ul className="space-y-2">
                      {analysis.evolution.map((development, i) => (
                        <li key={i} className="flex items-start gap-2">
                          <div className="w-2 h-2 rounded-full bg-blue-500 mt-2" />
                          <span>{development}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                  <div>
                    <h4 className="text-sm text-gray-500 mb-3">Perspective Shifts</h4>
                    <ul className="space-y-2">
                      {analysis.perspectiveShifts.map((shift, i) => (
                        <li key={i} className="flex items-start gap-2">
                          <div className="w-2 h-2 rounded-full bg-purple-500 mt-2" />
                          <span>{shift}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          ) : null}
        </DialogContent>
      </Dialog>
    </main>
  )
}
