//
//  ContentView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        ZStack {
            switch appState.currentRoute {
                case .splash:
                    ProgressView() // O una Splash Screen chula
                case .auth:
                    SignInView()
                case .onboarding:
                    OnboardingContainerView() // Pasos 2 a 9 de tu workflow
                case .main:
                    DashboardView()
            }
        }
        .animation(.spring(), value: appState.currentRoute)
    }
}

#Preview {
    @Previewable @State var appState = AppState(dataService: MockDataService.shared)
    
    ContentView()
        .environment(appState)
}
