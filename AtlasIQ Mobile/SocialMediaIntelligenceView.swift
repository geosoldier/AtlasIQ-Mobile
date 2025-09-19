//
//  SocialMediaIntelligenceView.swift
//  AtlasIQ Mobile
//
//  Created by EWA Kalyna Vision on 9/18/25.
//

import SwiftUI
import CoreLocation

struct SocialMediaIntelligenceView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var metaAPIManager = MetaAPIManager(appID: "YOUR_APP_ID", appSecret: "YOUR_APP_SECRET")
    @StateObject private var sentimentAnalyzer = SentimentAnalyzer()
    
    @State private var localSentiment: LocalSentiment?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showLocationPermission = false
    
    var body: some View {
        ZStack {
            // Background - Satellite map focused on DC area
            Image("satellite_map")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
                .ignoresSafeArea(.all)
            
            // Dark overlay for better text readability
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Title
                Text("Local Sentiment")
                    .font(.system(size: 32, weight: .light, design: .default))
                    .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.98))
                    .shadow(color: Color.blue.opacity(0.8), radius: 8, x: 0, y: 0)
                
                // Location Status
                if locationManager.isLocationEnabled {
                    LocationStatusView(locationManager: locationManager)
                }
                
                // Main Content
                if isLoading {
                    ProgressView("Analyzing Local Sentiment...")
                        .foregroundColor(.white)
                        .shadow(color: Color.blue.opacity(0.6), radius: 6, x: 0, y: 0)
                } else if let sentiment = localSentiment {
                    SentimentResultsView(sentiment: sentiment)
                } else if let error = errorMessage {
                    ErrorView(message: error) {
                        analyzeLocalSentiment()
                    }
                } else {
                    WelcomeView {
                        if locationManager.authorizationStatus == .notDetermined {
                            showLocationPermission = true
                        } else {
                            analyzeLocalSentiment()
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showLocationPermission) {
            LocationPermissionView(locationManager: locationManager) {
                showLocationPermission = false
                analyzeLocalSentiment()
            }
        }
        .onAppear {
            if locationManager.authorizationStatus == .notDetermined {
                showLocationPermission = true
            }
        }
    }
    
    private func analyzeLocalSentiment() {
        guard locationManager.isLocationEnabled else {
            errorMessage = "Location access is required for local sentiment analysis"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Get current location
                let location = try await withCheckedThrowingContinuation { continuation in
                    locationManager.getCurrentLocation { result in
                        continuation.resume(with: result)
                    }
                }
                
                // Search for local Facebook places
                let places = try await metaAPIManager.searchFacebookPlaces(location: location)
                
                // Fetch posts from local places
                var allPosts: [SocialMediaPost] = []
                for place in places.prefix(5) { // Limit to first 5 places
                    let posts = try await metaAPIManager.fetchPagePosts(pageID: place.id)
                    allPosts.append(contentsOf: posts)
                }
                
                // Analyze sentiment
                let sentiment = sentimentAnalyzer.aggregateSentiment(allPosts)
                
                await MainActor.run {
                    self.localSentiment = sentiment
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct WelcomeView: View {
    let onAnalyze: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .font(.system(size: 40))
                .foregroundColor(.white)
            
            Text("Monitor platforms, analyze sentiment")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Button("Analyze Local Sentiment") {
                onAnalyze()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

struct SentimentResultsView: View {
    let sentiment: LocalSentiment
    
    var body: some View {
        VStack(spacing: 16) {
            // Overall Sentiment
            SentimentCard(
                title: "Overall Sentiment",
                score: sentiment.overallSentiment.score,
                confidence: sentiment.overallSentiment.confidence,
                color: sentimentColor(sentiment.overallSentiment.score)
            )
            
            // Platform-specific sentiment
            HStack(spacing: 12) {
                SentimentCard(
                    title: "Facebook",
                    score: sentiment.facebookSentiment.score,
                    confidence: sentiment.facebookSentiment.confidence,
                    color: .blue
                )
                
                SentimentCard(
                    title: "Instagram",
                    score: sentiment.instagramSentiment.score,
                    confidence: sentiment.instagramSentiment.confidence,
                    color: .purple
                )
            }
            
            // Statistics
            VStack(spacing: 8) {
                Text("Analysis Summary")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Text("Total Posts: \(sentiment.totalPosts)")
                    Spacer()
                    Text("Updated: \(sentiment.timestamp, style: .time)")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private func sentimentColor(_ score: Double) -> Color {
        if score > 0.2 {
            return .green
        } else if score < -0.2 {
            return .red
        } else {
            return .yellow
        }
    }
}

struct SentimentCard: View {
    let title: String
    let score: Double
    let confidence: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Text(sentimentText(score))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text("Confidence: \(Int(confidence * 100))%")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func sentimentText(_ score: Double) -> String {
        if score > 0.2 {
            return "Positive"
        } else if score < -0.2 {
            return "Negative"
        } else {
            return "Neutral"
        }
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
        }
    }
}

#Preview {
    SocialMediaIntelligenceView()
}
