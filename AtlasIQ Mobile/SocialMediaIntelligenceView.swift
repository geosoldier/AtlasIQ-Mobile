//
//  SocialMediaIntelligenceView.swift
//  AtlasIQ Mobile
//
//  Created by EWA Kalyna Vision on 9/18/25.
//

import SwiftUI

struct SocialMediaIntelligenceView: View {
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
                
                Text("Local Sentiment")
                    .font(.system(size: 32, weight: .light, design: .default))
                    .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.98))
                    .shadow(color: Color.blue.opacity(0.8), radius: 8, x: 0, y: 0)
                
                Text("Coming Soon")
                    .font(.system(size: 18, weight: .regular, design: .default))
                    .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.98))
                    .shadow(color: Color.blue.opacity(0.6), radius: 6, x: 0, y: 0)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SocialMediaIntelligenceView()
}
