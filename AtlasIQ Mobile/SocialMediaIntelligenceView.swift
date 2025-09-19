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
    @State private var showBreakdown = false
    @State private var selectedBreakdown: SentimentBreakdown?
    
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
                    SentimentResultsView(
                        sentiment: sentiment,
                        showBreakdown: $showBreakdown,
                        selectedBreakdown: $selectedBreakdown
                    )
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
        .sheet(isPresented: $showBreakdown) {
            VStack {
                Text("Debug: showBreakdown=\(showBreakdown), selectedBreakdown=\(selectedBreakdown?.factors.count ?? 0)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                
                if let breakdown = selectedBreakdown {
                    SentimentBreakdownView(breakdown: breakdown)
                        .onAppear {
                            print("Presenting breakdown with \(breakdown.factors.count) factors")
                        }
                } else {
                    Text("No breakdown data available")
                        .padding()
                        .onAppear {
                            print("No breakdown selected")
                        }
                }
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
        
        // Overall sentiment breakdown
        let overallBreakdown = SentimentBreakdown(
            factors: [
                SentimentFactor(category: "Transportation", description: "Traffic delays reported on main routes", impact: -0.3, source: "Facebook"),
                SentimentFactor(category: "Events", description: "University graduation ceremonies creating positive buzz", impact: 0.4, source: "Instagram"),
                SentimentFactor(category: "Weather", description: "Sunny weather improving community mood", impact: 0.2, source: "Facebook"),
                SentimentFactor(category: "Safety", description: "Minor increase in petty crime reports", impact: -0.1, source: "News")
            ],
            summary: "Overall sentiment is positive due to celebratory events and good weather, despite some traffic concerns and minor safety issues."
        )
        
        let overallSentiment = SentimentScore(
            score: 0.2, // Slightly positive sentiment for Cambridge
            confidence: 0.85,
            emotions: [
                "joy": 0.25,
                "sadness": 0.08,
                "anger": 0.05,
                "surprise": 0.12
            ],
            breakdown: overallBreakdown
        )
        
        // Facebook sentiment breakdown
        let facebookBreakdown = SentimentBreakdown(
            factors: [
                SentimentFactor(category: "Transportation", description: "Multiple posts about traffic congestion", impact: -0.4, source: "Facebook"),
                SentimentFactor(category: "Community", description: "Positive posts about local businesses", impact: 0.3, source: "Facebook"),
                SentimentFactor(category: "Events", description: "Graduation celebration posts", impact: 0.2, source: "Facebook")
            ],
            summary: "Facebook sentiment is moderately positive with community celebrations outweighing traffic complaints."
        )
        
        let facebookSentiment = SentimentScore(
            score: 0.15, // Positive sentiment on Facebook
            confidence: 0.78,
            emotions: [
                "joy": 0.22,
                "sadness": 0.06,
                "anger": 0.03
            ],
            breakdown: facebookBreakdown
        )
        
        // Instagram sentiment breakdown
        let instagramBreakdown = SentimentBreakdown(
            factors: [
                SentimentFactor(category: "Events", description: "Graduation photos and celebrations", impact: 0.5, source: "Instagram"),
                SentimentFactor(category: "Weather", description: "Beautiful sunset photos shared", impact: 0.3, source: "Instagram"),
                SentimentFactor(category: "Food", description: "Positive reviews of local restaurants", impact: 0.2, source: "Instagram")
            ],
            summary: "Instagram sentiment is very positive with graduation celebrations and beautiful weather photos dominating the feed."
        )
        
        let instagramSentiment = SentimentScore(
            score: 0.35, // More positive on Instagram
            confidence: 0.82,
            emotions: [
                "joy": 0.28,
                "surprise": 0.15,
                "sadness": 0.04
            ],
            breakdown: instagramBreakdown
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
    @Binding var showBreakdown: Bool
    @Binding var selectedBreakdown: SentimentBreakdown?
    
    var body: some View {
        VStack(spacing: 16) {
            // Overall Sentiment
            SentimentCard(
                title: "Overall Sentiment",
                score: sentiment.overallSentiment.score,
                confidence: sentiment.overallSentiment.confidence,
                color: sentimentColor(sentiment.overallSentiment.score),
                isTappable: true
            ) {
                print("Overall sentiment tapped - breakdown: \(sentiment.overallSentiment.breakdown)")
                selectedBreakdown = sentiment.overallSentiment.breakdown
                print("selectedBreakdown set to: \(selectedBreakdown?.factors.count ?? 0) factors")
                showBreakdown = true
                print("showBreakdown set to: \(showBreakdown)")
            }
            
            // Platform-specific sentiment
            HStack(spacing: 12) {
                SentimentCard(
                    title: "Facebook",
                    score: sentiment.facebookSentiment.score,
                    confidence: sentiment.facebookSentiment.confidence,
                    color: sentimentColor(sentiment.facebookSentiment.score),
                    isTappable: true
                ) {
                    selectedBreakdown = sentiment.facebookSentiment.breakdown
                    showBreakdown = true
                }
                
                SentimentCard(
                    title: "Instagram",
                    score: sentiment.instagramSentiment.score,
                    confidence: sentiment.instagramSentiment.confidence,
                    color: sentimentColor(sentiment.instagramSentiment.score),
                    isTappable: true
                ) {
                    selectedBreakdown = sentiment.instagramSentiment.breakdown
                    showBreakdown = true
                }
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
    let isTappable: Bool
    let onTap: (() -> Void)?
    
    init(title: String, score: Double, confidence: Double, color: Color, isTappable: Bool = false, onTap: (() -> Void)? = nil) {
        self.title = title
        self.score = score
        self.confidence = confidence
        self.color = color
        self.isTappable = isTappable
        self.onTap = onTap
    }
    
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
            
            if isTappable {
                Text("Tap for details")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .italic()
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .onTapGesture {
            if isTappable {
                onTap?()
            }
        }
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

struct SentimentBreakdownView: View {
    let breakdown: SentimentBreakdown
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Debug info
                    Text("Debug: \(breakdown.factors.count) factors")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                    // Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Summary")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(breakdown.summary)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Factors
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Contributing Factors")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ForEach(Array(breakdown.factors.enumerated()), id: \.offset) { index, factor in
                            SentimentFactorRow(factor: factor)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Sentiment Breakdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SentimentFactorRow: View {
    let factor: SentimentFactor
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Impact indicator
            Circle()
                .fill(impactColor(factor.impact))
                .frame(width: 12, height: 12)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(factor.category)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(factor.source)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
                
                Text(factor.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func impactColor(_ impact: Double) -> Color {
        if impact > 0.2 {
            return Color(red: 0.0, green: 1.0, blue: 0.0) // Bright green
        } else if impact < -0.2 {
            return Color(red: 1.0, green: 0.0, blue: 0.0) // Bright red
        } else {
            return Color(red: 1.0, green: 1.0, blue: 0.0) // Bright yellow
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
