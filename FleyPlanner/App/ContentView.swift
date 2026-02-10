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
                    ProgressView() // Splash Screen chula
                case .auth:
                    SignInView()
                case .onboarding:
                    OnboardingContainerView()
                case .main:
                    AppRootView()
            }
        }
        .animation(.spring(), value: appState.currentRoute)
        .onAppear {
            print("Init ContentView: \(appState.currentRoute)")
        }
    }
}
