//
//  MainPageView.swift
//  AtlasIQ Mobile
//
//  Created by EWA Kalyna Vision on 9/18/25.
//

import SwiftUI

struct MainPageView: View {
    var body: some View {
        NavigationView {
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
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // AtlasIQ Logo/Title
                    Text("AtlasIQ")
                        .font(.system(size: 48, weight: .light, design: .default))
                        .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.98)) // Bone white
                        .shadow(color: Color.blue.opacity(1.0), radius: 8, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.9), radius: 16, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.7), radius: 24, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.5), radius: 32, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.3), radius: 40, x: 0, y: 0)
                    
                    // Tagline
                    Text("Clarity Out Of Complexity")
                        .font(.system(size: 18, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.98)) // Bone white
                        .shadow(color: Color.blue.opacity(0.9), radius: 6, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.7), radius: 12, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.5), radius: 18, x: 0, y: 0)
                        .shadow(color: Color.blue.opacity(0.3), radius: 24, x: 0, y: 0)
                    
                    Spacer()
                    
                    // Main Options
                    VStack(spacing: 20) {
                        // Option 1: Social Media Intelligence
                        NavigationLink(destination: SocialMediaIntelligenceView()) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Social Media Intelligence")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Monitor platforms, analyze sentiment")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    // Liquid glass background
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.clear)
                                        .background(Color.white.opacity(0.1))
                                    
                                    // Subtle gradient overlay
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.1),
                                                    Color.clear,
                                                    Color.black.opacity(0.1)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // Beveled edge effect
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.clear,
                                                    Color.black.opacity(0.2)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                }
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        // Option 2: Threat Assessment
                        NavigationLink(destination: ThreatAssessmentView()) {
                            HStack {
                                Image(systemName: "shield.checkered")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Threat Assessment")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Predictive analytics and risk analysis")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    // Liquid glass background
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.clear)
                                        .background(Color.white.opacity(0.1))
                                    
                                    // Subtle gradient overlay
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.1),
                                                    Color.clear,
                                                    Color.black.opacity(0.1)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // Beveled edge effect
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.clear,
                                                    Color.black.opacity(0.2)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                }
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                            .shadow(color: Color.red.opacity(0.2), radius: 12, x: 0, y: 0)
                        }
                        
                        // Option 3: Intelligence Reports
                        NavigationLink(destination: IntelligenceReportsView()) {
                            HStack {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Intelligence Reports")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Generate comprehensive OSINT reports")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    // Liquid glass background
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.clear)
                                        .background(Color.white.opacity(0.1))
                                    
                                    // Subtle gradient overlay
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.1),
                                                    Color.clear,
                                                    Color.black.opacity(0.1)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    // Beveled edge effect
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.clear,
                                                    Color.black.opacity(0.2)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                }
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                            .shadow(color: Color.green.opacity(0.2), radius: 12, x: 0, y: 0)
                        }
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                    
                    Spacer()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    MainPageView()
}
