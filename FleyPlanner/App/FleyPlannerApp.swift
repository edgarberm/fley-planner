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
                .preferredColorScheme(.light)
                .task {
                    await appState.initializeSession()
                }
        }
    }
}
