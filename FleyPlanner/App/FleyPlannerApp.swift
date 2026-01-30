//
//  FleyPlannerApp.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

@main
struct FleyPlannerApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .task {
                    print("🟡 App started, auto-signing in Edgar...")
                    await appState.signIn(userId: MockData.shared.edgar.id)
                    print("🟢 Current user: \(appState.currentUser?.name ?? "nil")")
                }
        }
    }
}
