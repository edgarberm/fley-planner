//
//  AppRootView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 4/2/26.
//

import SwiftUI

// MARK: - App Root View (Simple)

struct AppRootView: View {
    @Environment(AppState.self) private var appState
    @Environment(AppRouter.self) private var router
    
    
    var body: some View {
        ZStack {
            // Dashboard (siempre visible)
            DashboardView()
            
            // Settings overlay
            RouterFullScreenCover(isPresented: router.showSettings) {
                SettingsView()
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: router.showSettings)
    }
}

// MARK: - Settings View (Placeholder)

struct SettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle.bold())
            
            
            ForEach(0..<60) { i in
                Text("Elemento \(i)")
            }
            
        }
    }
}
