//
//  SentimentAnalyzer.swift
//  AtlasIQ Mobile
//
//  Created by EWA Kalyna Vision on 9/19/25.
//

import Foundation
import NaturalLanguage
import CoreLocation

// MARK: - Sentiment Analysis Engine
class SentimentAnalyzer: ObservableObject {
    
    // MARK: - Properties
    private let sentimentTagger = NLTagger(tagSchemes: [.sentimentScore])
    private let emotionTagger = NLTagger(tagSchemes: [.sentimentScore])
    
    // Sentiment keywords for enhanced analysis
    private let positiveKeywords = [
        "great", "excellent", "amazing", "wonderful", "fantastic", "awesome",
        "love", "like", "enjoy", "happy", "pleased", "satisfied", "good",
        "best", "perfect", "outstanding", "brilliant", "superb", "marvelous"
    ]
    
    private let negativeKeywords = [
        "terrible", "awful", "horrible", "disgusting", "hate", "dislike",
        "angry", "frustrated", "disappointed", "sad", "bad", "worst",
        "annoying", "irritating", "frustrating", "upset", "mad", "furious"
    ]
    
    private let neutralKeywords = [
        "okay", "fine", "average", "normal", "regular", "standard",
        "acceptable", "decent", "fair", "moderate", "typical"
    ]
    
    // MARK: - Public Methods
    
    /// Analyze sentiment of a single text
    func analyzeText(_ text: String) -> SentimentScore {
        let cleanedText = preprocessText(text)
        
        // Use Natural Language framework for basic sentiment
        let nlSentiment = analyzeWithNaturalLanguage(cleanedText)
        
        // Use keyword analysis for enhanced accuracy
        let keywordSentiment = analyzeWithKeywords(cleanedText)
        
        // Combine both approaches
        let combinedScore = combineSentimentScores(nlSentiment, keywordSentiment)
        
        // Analyze emotions
        let emotions = analyzeEmotions(cleanedText)
        
        return SentimentScore(
            score: combinedScore.score,
            confidence: combinedScore.confidence,
            emotions: emotions
        )
    }
    
    /// Analyze sentiment of a Facebook post
    func analyzeFacebookPost(_ post: FacebookPost) -> SentimentScore {
        var text = post.message ?? ""
        
        // Consider engagement metrics
        let engagementScore = calculateEngagementScore(
            likes: post.likesCount,
            comments: post.commentsCount,
            shares: post.sharesCount
        )
        
        // Analyze the main text
        let textSentiment = analyzeText(text)
        
        // Adjust sentiment based on engagement
        let adjustedScore = adjustSentimentForEngagement(textSentiment, engagementScore)
        
        return adjustedScore
    }
    
    /// Analyze sentiment of an Instagram post
    func analyzeInstagramPost(_ post: InstagramPost) -> SentimentScore {
        var text = post.caption ?? ""
        
        // Consider engagement metrics
        let engagementScore = calculateEngagementScore(
            likes: post.likesCount,
            comments: post.commentsCount,
            shares: 0 // Instagram doesn't have shares
        )
        
        // Analyze the main text
        let textSentiment = analyzeText(text)
        
        // Adjust sentiment based on engagement
        let adjustedScore = adjustSentimentForEngagement(textSentiment, engagementScore)
        
        return adjustedScore
    }
    
    /// Aggregate sentiment from multiple posts
    func aggregateSentiment(_ posts: [SocialMediaPost]) -> LocalSentiment {
        guard !posts.isEmpty else {
            return LocalSentiment(
                location: CLLocation(latitude: 0, longitude: 0),
                overallSentiment: SentimentScore(score: 0, confidence: 0, emotions: [:]),
                facebookSentiment: SentimentScore(score: 0, confidence: 0, emotions: [:]),
                instagramSentiment: SentimentScore(score: 0, confidence: 0, emotions: [:]),
                totalPosts: 0,
                timestamp: Date()
            )
        }
        
        let facebookPosts = posts.compactMap { $0 as? FacebookPost }
        let instagramPosts = posts.compactMap { $0 as? InstagramPost }
        
        // Calculate overall sentiment
        let overallSentiment = calculateOverallSentiment(posts)
        
        // Calculate platform-specific sentiment
        let facebookSentiment = calculatePlatformSentiment(facebookPosts)
        let instagramSentiment = calculatePlatformSentiment(instagramPosts)
        
        // Get location from first post (assuming all posts are from same area)
        let location = posts.first?.location ?? CLLocation(latitude: 0, longitude: 0)
        
        return LocalSentiment(
            location: location,
            overallSentiment: overallSentiment,
            facebookSentiment: facebookSentiment,
            instagramSentiment: instagramSentiment,
            totalPosts: posts.count,
            timestamp: Date()
        )
    }
    
    // MARK: - Private Methods
    
    private func preprocessText(_ text: String) -> String {
        // Remove URLs, mentions, and hashtags
        var cleanedText = text
        
        // Remove URLs
        cleanedText = cleanedText.replacingOccurrences(of: #"https?://\S+"#, with: "", options: .regularExpression)
        
        // Remove mentions (@username)
        cleanedText = cleanedText.replacingOccurrences(of: #"@\w+"#, with: "", options: .regularExpression)
        
        // Remove hashtags (#hashtag)
        cleanedText = cleanedText.replacingOccurrences(of: #"#\w+"#, with: "", options: .regularExpression)
        
        // Remove extra whitespace
        cleanedText = cleanedText.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        
        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func analyzeWithNaturalLanguage(_ text: String) -> SentimentScore {
        sentimentTagger.string = text
        
        var sentimentScore: Double = 0.0
        var confidence: Double = 0.0
        
        sentimentTagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .paragraph, scheme: .sentimentScore) { tag, range in
            if let tag = tag {
                sentimentScore = Double(tag.rawValue) ?? 0.0
                confidence = 0.8 // Natural Language framework confidence
            }
            return true
        }
        
        return SentimentScore(score: sentimentScore, confidence: confidence, emotions: [:])
    }
    
    private func analyzeWithKeywords(_ text: String) -> SentimentScore {
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        
        var positiveCount = 0
        var negativeCount = 0
        var neutralCount = 0
        
        for word in words {
            if positiveKeywords.contains(word) {
                positiveCount += 1
            } else if negativeKeywords.contains(word) {
                negativeCount += 1
            } else if neutralKeywords.contains(word) {
                neutralCount += 1
            }
        }
        
        let totalKeywords = positiveCount + negativeCount + neutralCount
        
        if totalKeywords == 0 {
            return SentimentScore(score: 0, confidence: 0, emotions: [:])
        }
        
        let score = Double(positiveCount - negativeCount) / Double(totalKeywords)
        let confidence = Double(totalKeywords) / Double(words.count)
        
        return SentimentScore(score: score, confidence: confidence, emotions: [:])
    }
    
    private func combineSentimentScores(_ nlScore: SentimentScore, _ keywordScore: SentimentScore) -> SentimentScore {
        // Weight Natural Language analysis more heavily
        let weightNL = 0.7
        let weightKeywords = 0.3
        
        let combinedScore = (nlScore.score * weightNL) + (keywordScore.score * weightKeywords)
        let combinedConfidence = (nlScore.confidence * weightNL) + (keywordScore.confidence * weightKeywords)
        
        return SentimentScore(score: combinedScore, confidence: combinedConfidence, emotions: [:])
    }
    
    private func analyzeEmotions(_ text: String) -> [String: Double] {
        // Since .emotion is not available in NLTagScheme, we'll use keyword analysis
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        
        var emotions: [String: Double] = [:]
        
        // Define emotion keywords
        let emotionKeywords: [String: [String]] = [
            "joy": ["happy", "joyful", "excited", "thrilled", "delighted", "cheerful"],
            "sadness": ["sad", "depressed", "down", "melancholy", "gloomy", "sorrowful"],
            "anger": ["angry", "mad", "furious", "rage", "irritated", "annoyed"],
            "fear": ["scared", "afraid", "terrified", "worried", "anxious", "nervous"],
            "surprise": ["surprised", "shocked", "amazed", "astonished", "stunned"],
            "disgust": ["disgusted", "revolted", "sickened", "repulsed", "appalled"]
        ]
        
        for (emotion, keywords) in emotionKeywords {
            let count = keywords.reduce(0) { count, keyword in
                count + words.filter { $0.contains(keyword) }.count
            }
            if count > 0 {
                emotions[emotion] = Double(count) / Double(words.count)
            }
        }
        
        return emotions
    }
    
    private func calculateEngagementScore(likes: Int, comments: Int, shares: Int) -> Double {
        // Normalize engagement metrics
        let totalEngagement = likes + (comments * 2) + (shares * 3)
        
        // Convert to sentiment influence (-1 to 1)
        if totalEngagement == 0 {
            return 0
        } else if totalEngagement < 10 {
            return 0.1
        } else if totalEngagement < 50 {
            return 0.3
        } else if totalEngagement < 100 {
            return 0.5
        } else {
            return 0.7
        }
    }
    
    private func adjustSentimentForEngagement(_ sentiment: SentimentScore, _ engagement: Double) -> SentimentScore {
        // High engagement can amplify sentiment
        let adjustedScore = sentiment.score * (1 + engagement)
        let adjustedConfidence = min(sentiment.confidence + (engagement * 0.2), 1.0)
        
        return SentimentScore(
            score: max(-1.0, min(1.0, adjustedScore)),
            confidence: adjustedConfidence,
            emotions: sentiment.emotions
        )
    }
    
    private func calculateOverallSentiment(_ posts: [SocialMediaPost]) -> SentimentScore {
        let sentiments = posts.map { post in
            if let facebookPost = post as? FacebookPost {
                return analyzeFacebookPost(facebookPost)
            } else if let instagramPost = post as? InstagramPost {
                return analyzeInstagramPost(instagramPost)
            } else {
                return SentimentScore(score: 0, confidence: 0, emotions: [:])
            }
        }
        
        guard !sentiments.isEmpty else {
            return SentimentScore(score: 0, confidence: 0, emotions: [:])
        }
        
        let averageScore = sentiments.map { $0.score }.reduce(0, +) / Double(sentiments.count)
        let averageConfidence = sentiments.map { $0.confidence }.reduce(0, +) / Double(sentiments.count)
        
        // Combine emotions
        var combinedEmotions: [String: Double] = [:]
        for sentiment in sentiments {
            for (emotion, value) in sentiment.emotions {
                combinedEmotions[emotion] = (combinedEmotions[emotion] ?? 0) + value
            }
        }
        
        // Normalize emotions
        let totalEmotions = combinedEmotions.values.reduce(0, +)
        if totalEmotions > 0 {
            for (emotion, value) in combinedEmotions {
                combinedEmotions[emotion] = value / totalEmotions
            }
        }
        
        return SentimentScore(score: averageScore, confidence: averageConfidence, emotions: combinedEmotions)
    }
    
    private func calculatePlatformSentiment(_ posts: [FacebookPost]) -> SentimentScore {
        let sentiments = posts.map { analyzeFacebookPost($0) }
        let averageScore = sentiments.map { $0.score }.reduce(0, +) / Double(sentiments.count)
        let averageConfidence = sentiments.map { $0.confidence }.reduce(0, +) / Double(sentiments.count)
        
        var combinedEmotions: [String: Double] = [:]
        for sentiment in sentiments {
            for (emotion, value) in sentiment.emotions {
                combinedEmotions[emotion] = (combinedEmotions[emotion] ?? 0) + value
            }
        }
        
        let totalEmotions = combinedEmotions.values.reduce(0, +)
        if totalEmotions > 0 {
            for (emotion, value) in combinedEmotions {
                combinedEmotions[emotion] = value / totalEmotions
            }
        }
        
        return SentimentScore(score: averageScore, confidence: averageConfidence, emotions: combinedEmotions)
    }
    
    private func calculatePlatformSentiment(_ posts: [InstagramPost]) -> SentimentScore {
        let sentiments = posts.map { analyzeInstagramPost($0) }
        let averageScore = sentiments.map { $0.score }.reduce(0, +) / Double(sentiments.count)
        let averageConfidence = sentiments.map { $0.confidence }.reduce(0, +) / Double(sentiments.count)
        
        var combinedEmotions: [String: Double] = [:]
        for sentiment in sentiments {
            for (emotion, value) in sentiment.emotions {
                combinedEmotions[emotion] = (combinedEmotions[emotion] ?? 0) + value
            }
        }
        
        let totalEmotions = combinedEmotions.values.reduce(0, +)
        if totalEmotions > 0 {
            for (emotion, value) in combinedEmotions {
                combinedEmotions[emotion] = value / totalEmotions
            }
        }
        
        return SentimentScore(score: averageScore, confidence: averageConfidence, emotions: combinedEmotions)
    }
}

// MARK: - Protocol for Social Media Posts
protocol SocialMediaPost {
    var id: String { get }
    var text: String? { get }
    var location: CLLocation? { get }
    var timestamp: Date { get }
}

// MARK: - Extensions
extension FacebookPost: SocialMediaPost {
    var text: String? { return message }
    var timestamp: Date { return createdTime }
}

extension InstagramPost: SocialMediaPost {
    var text: String? { return caption }
    // timestamp property already exists in InstagramPost struct
}
