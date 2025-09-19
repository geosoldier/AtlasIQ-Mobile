//
//  AtlasIQ_MobileApp.swift
//  AtlasIQ Mobile
//
//  Created by EWA Kalyna Vision on 9/16/25.
//

import SwiftUI
import FirebaseCore

@main
struct AtlasIQ_MobileApp: App {
    init() {
        // Configure Firebase at app launch
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
