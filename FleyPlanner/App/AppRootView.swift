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
            DashboardView()
                .scrollContentBackground(.hidden)
        }
        .fullScreenSheet(ignoreSafeArea: true, isPresented: Bindable(router).showSettings) { safeArea in
            overlayContent()
                .safeAreaPadding(.top, safeArea.top)
        } background: {
            defaultBackground()
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: router.showSettings)
    }
    
    @ViewBuilder
    func overlayContent() -> some View {
        SettingsView()
    }
}

// MARK: - Settings View (Placeholder)

struct SettingsView: View {
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text("Settings")
                    .font(.largeTitle.bold())
                    .listRowBackground(Color.clear)
                
                ForEach(0..<100) { i in
                    Text("Elemento \(i)")
                        .listRowBackground(Color.clear)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .scrollContentBackground(.hidden)
    }
}
