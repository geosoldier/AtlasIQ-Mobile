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
                print("LocationPermissionView completion called")
                showLocationPermission = false
                // Don't auto-analyze, let user tap the button
            }
        }
        .onAppear {
            print("SocialMediaIntelligenceView appeared")
            print("Current authorization status: \(locationManager.authorizationStatus.rawValue)")
            print("Location enabled: \(locationManager.isLocationEnabled)")
            
            if locationManager.authorizationStatus == .notDetermined {
                print("Showing location permission sheet")
                showLocationPermission = true
            } else if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
                print("Location already authorized, showing welcome view")
                showLocationPermission = false
            }
        }
        .onChange(of: locationManager.authorizationStatus) { status in
            print("Location authorization status changed to: \(status.rawValue)")
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                showLocationPermission = false
                print("Location permission granted, dismissing permission view")
                // Don't auto-analyze, let user choose when to analyze
            }
        }
        .onChange(of: locationManager.isLocationEnabled) { isEnabled in
            print("Location enabled status changed to: \(isEnabled)")
        }
    }
    
    private func analyzeLocalSentiment() {
        print("analyzeLocalSentiment() called")
        print("Authorization status: \(locationManager.authorizationStatus.rawValue)")
        
        guard locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways else {
            print("Location not authorized, showing error")
            errorMessage = "Location access is required for local sentiment analysis"
            return
        }
        
        print("Starting sentiment analysis...")
        isLoading = true
        errorMessage = nil
        
        Task {
            // For simulator testing, use Cambridge UK coordinates immediately
            // In production, this would use real location data
            let location = CLLocation(latitude: 52.2053, longitude: 0.1218) // Cambridge, UK
            
            print("Using Cambridge, UK location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            // Create mock sentiment data for Cambridge, UK
            let mockSentiment = createMockSentimentData(location: location)
            
            print("Created mock sentiment data, updating UI...")
            
            await MainActor.run {
                self.localSentiment = mockSentiment
                self.isLoading = false
                print("UI updated with sentiment results")
            }
        }
    }
    
    private func createMockSentimentData(location: CLLocation) -> LocalSentiment {
        // Create mock sentiment data for Cambridge, UK
        let overallSentiment = SentimentScore(
            score: 0.2, // Slightly positive sentiment for Cambridge
            confidence: 0.85,
            emotions: [
                "joy": 0.25,
                "sadness": 0.08,
                "anger": 0.05,
                "surprise": 0.12
            ]
        )
        
        let facebookSentiment = SentimentScore(
            score: 0.15, // Positive sentiment on Facebook
            confidence: 0.78,
            emotions: [
                "joy": 0.22,
                "sadness": 0.06,
                "anger": 0.03
            ]
        )
        
        let instagramSentiment = SentimentScore(
            score: 0.35, // More positive on Instagram
            confidence: 0.82,
            emotions: [
                "joy": 0.28,
                "surprise": 0.15,
                "sadness": 0.04
            ]
        )
        
        return LocalSentiment(
            location: location,
            overallSentiment: overallSentiment,
            facebookSentiment: facebookSentiment,
            instagramSentiment: instagramSentiment,
            totalPosts: 32, // Realistic post count for Cambridge area
            timestamp: Date()
        )
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
            
            Text("Tap below to analyze local sentiment from social media posts in your area")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Button("Analyze Local Sentiment") {
                print("Analyze button tapped")
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
                    color: sentimentColor(sentiment.facebookSentiment.score)
                )
                
                SentimentCard(
                    title: "Instagram",
                    score: sentiment.instagramSentiment.score,
                    confidence: sentiment.instagramSentiment.confidence,
                    color: sentimentColor(sentiment.instagramSentiment.score)
                )
            }
            
            // Statistics
            VStack(spacing: 8) {
                Text("Analysis Summary")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(spacing: 4) {
                    Text("Total Posts: \(sentiment.totalPosts)")
                        .multilineTextAlignment(.center)
                    Text("Updated: \(sentiment.timestamp, style: .time)")
                        .multilineTextAlignment(.center)
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private func sentimentColor(_ score: Double) -> Color {
        if score > 0.2 {
            return Color(red: 0.0, green: 1.0, blue: 0.0) // Bright green
        } else if score < -0.2 {
            return Color(red: 1.0, green: 0.0, blue: 0.0) // Bright red
        } else {
            return Color(red: 1.0, green: 1.0, blue: 0.0) // Bright yellow
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
