//
//  MetaAPIManager.swift
//  AtlasIQ Mobile
//
//  Created by EWA Kalyna Vision on 9/19/25.
//

import Foundation
import CoreLocation

// MARK: - Meta API Models
struct FacebookPost {
    let id: String
    let message: String?
    let createdTime: Date
    let location: CLLocation?
    let pageName: String
    let likesCount: Int
    let commentsCount: Int
    let sharesCount: Int
}

struct InstagramPost {
    let id: String
    let caption: String?
    let mediaType: String
    let mediaURL: String
    let timestamp: Date
    let location: CLLocation?
    let likesCount: Int
    let commentsCount: Int
}

struct FacebookPlace {
    let id: String
    let name: String
    let location: CLLocation
    let category: String
    let checkinsCount: Int
}

struct InstagramLocation {
    let id: String
    let name: String
    let location: CLLocation
    let mediaCount: Int
}

struct SentimentScore {
    let score: Double // -1.0 to 1.0 (negative to positive)
    let confidence: Double // 0.0 to 1.0
    let emotions: [String: Double] // emotion -> confidence
    let breakdown: SentimentBreakdown // Detailed factors driving the sentiment
}

struct SentimentBreakdown {
    let factors: [SentimentFactor]
    let summary: String
}

struct SentimentFactor {
    let category: String // e.g., "Transportation", "Safety", "Events"
    let description: String // e.g., "Traffic delays reported"
    let impact: Double // -1.0 to 1.0 (how much this factor contributes)
    let source: String // e.g., "Facebook", "Instagram", "News"
}

struct LocalSentiment {
    let location: CLLocation
    let overallSentiment: SentimentScore
    let facebookSentiment: SentimentScore
    let instagramSentiment: SentimentScore
    let totalPosts: Int
    let timestamp: Date
}

// MARK: - Meta API Manager
class MetaAPIManager: ObservableObject {
    // MARK: - Properties
    private let appID: String
    private let appSecret: String
    private var accessToken: String?
    private let baseURL = "https://graph.facebook.com/v18.0"
    
    // Rate limiting
    private var callCount = 0
    private var lastReset = Date()
    private let maxCallsPerHour = 200
    
    // MARK: - Initialization
    init(appID: String, appSecret: String) {
        self.appID = appID
        self.appSecret = appSecret
    }
    
    // MARK: - Authentication
    func authenticate() async throws -> Bool {
        // This would typically involve OAuth flow
        // For now, we'll implement a placeholder
        return true
    }
    
    // MARK: - Facebook API Methods
    func searchFacebookPlaces(location: CLLocation, radius: Double = 16093.4) async throws -> [FacebookPlace] {
        guard try await canMakeCall() else {
            throw MetaAPIError.rateLimitExceeded
        }
        
        let urlString = "\(baseURL)/search"
        var components = URLComponents(string: urlString)
        
        components?.queryItems = [
            URLQueryItem(name: "q", value: "restaurant"),
            URLQueryItem(name: "type", value: "place"),
            URLQueryItem(name: "center", value: "\(location.coordinate.latitude),\(location.coordinate.longitude)"),
            URLQueryItem(name: "distance", value: "\(Int(radius))"),
            URLQueryItem(name: "access_token", value: accessToken ?? "")
        ]
        
        guard let url = components?.url else {
            throw MetaAPIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MetaAPIError.requestFailed
        }
        
        let places = try JSONDecoder().decode(FacebookPlacesResponse.self, from: data)
        return places.data.map { place in
            FacebookPlace(
                id: place.id,
                name: place.name,
                location: CLLocation(
                    latitude: place.location.latitude,
                    longitude: place.location.longitude
                ),
                category: place.category,
                checkinsCount: place.checkinsCount ?? 0
            )
        }
    }
    
    func fetchPagePosts(pageID: String, limit: Int = 25) async throws -> [FacebookPost] {
        guard try await canMakeCall() else {
            throw MetaAPIError.rateLimitExceeded
        }
        
        let urlString = "\(baseURL)/\(pageID)/posts"
        var components = URLComponents(string: urlString)
        
        components?.queryItems = [
            URLQueryItem(name: "fields", value: "id,message,created_time,place,likes.summary(true),comments.summary(true),shares"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "access_token", value: accessToken ?? "")
        ]
        
        guard let url = components?.url else {
            throw MetaAPIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MetaAPIError.requestFailed
        }
        
        let posts = try JSONDecoder().decode(FacebookPostsResponse.self, from: data)
        return posts.data.map { post in
            FacebookPost(
                id: post.id,
                message: post.message,
                createdTime: post.createdTime,
                location: post.place.map { 
                    CLLocation(latitude: $0.location.latitude, longitude: $0.location.longitude) 
                },
                pageName: post.pageName ?? "Unknown",
                likesCount: post.likes?.summary?.totalCount ?? 0,
                commentsCount: post.comments?.summary?.totalCount ?? 0,
                sharesCount: post.shares?.count ?? 0
            )
        }
    }
    
    // MARK: - Instagram API Methods
    func searchInstagramLocations(location: CLLocation, radius: Double = 16093.4) async throws -> [InstagramLocation] {
        guard try await canMakeCall() else {
            throw MetaAPIError.rateLimitExceeded
        }
        
        // Instagram location search implementation
        // This would require Instagram Business Account setup
        return []
    }
    
    func fetchInstagramMedia(userID: String, limit: Int = 25) async throws -> [InstagramPost] {
        guard try await canMakeCall() else {
            throw MetaAPIError.rateLimitExceeded
        }
        
        let urlString = "\(baseURL)/\(userID)/media"
        var components = URLComponents(string: urlString)
        
        components?.queryItems = [
            URLQueryItem(name: "fields", value: "id,caption,media_type,media_url,timestamp,location,like_count,comments_count"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "access_token", value: accessToken ?? "")
        ]
        
        guard let url = components?.url else {
            throw MetaAPIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MetaAPIError.requestFailed
        }
        
        let media = try JSONDecoder().decode(InstagramMediaResponse.self, from: data)
        return media.data.map { item in
            InstagramPost(
                id: item.id,
                caption: item.caption,
                mediaType: item.mediaType,
                mediaURL: item.mediaURL,
                timestamp: item.timestamp,
                location: item.location.map { 
                    CLLocation(latitude: $0.latitude, longitude: $0.longitude) 
                },
                likesCount: item.likeCount ?? 0,
                commentsCount: item.commentsCount ?? 0
            )
        }
    }
    
    // MARK: - Rate Limiting
    private func canMakeCall() async throws -> Bool {
        let now = Date()
        
        // Reset counter if hour has passed
        if now.timeIntervalSince(lastReset) >= 3600 {
            callCount = 0
            lastReset = now
        }
        
        // Check if we can make another call
        if callCount >= maxCallsPerHour {
            throw MetaAPIError.rateLimitExceeded
        }
        
        callCount += 1
        return true
    }
}

// MARK: - API Response Models
struct FacebookPlacesResponse: Codable {
    let data: [FacebookPlaceData]
}

struct FacebookPlaceData: Codable {
    let id: String
    let name: String
    let location: FacebookLocationData
    let category: String
    let checkinsCount: Int?
}

struct FacebookLocationData: Codable {
    let latitude: Double
    let longitude: Double
}

struct FacebookPostsResponse: Codable {
    let data: [FacebookPostData]
}

struct FacebookPostData: Codable {
    let id: String
    let message: String?
    let createdTime: Date
    let place: FacebookPlaceData?
    let likes: FacebookLikesData?
    let comments: FacebookCommentsData?
    let shares: FacebookSharesData?
    let pageName: String?
}

struct FacebookLikesData: Codable {
    let summary: FacebookSummaryData?
}

struct FacebookCommentsData: Codable {
    let summary: FacebookSummaryData?
}

struct FacebookSharesData: Codable {
    let count: Int
}

struct FacebookSummaryData: Codable {
    let totalCount: Int
}

struct InstagramMediaResponse: Codable {
    let data: [InstagramMediaData]
}

struct InstagramMediaData: Codable {
    let id: String
    let caption: String?
    let mediaType: String
    let mediaURL: String
    let timestamp: Date
    let location: InstagramLocationData?
    let likeCount: Int?
    let commentsCount: Int?
}

struct InstagramLocationData: Codable {
    let latitude: Double
    let longitude: Double
}

// MARK: - Errors
enum MetaAPIError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case rateLimitExceeded
    case authenticationFailed
    case dataParsingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for API request"
        case .requestFailed:
            return "API request failed"
        case .rateLimitExceeded:
            return "API rate limit exceeded"
        case .authenticationFailed:
            return "Authentication failed"
        case .dataParsingFailed:
            return "Failed to parse API response data"
        }
    }
}
