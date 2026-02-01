//
//  OnboardingContainerView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

struct OnboardingContainerView: View {
    @Environment(AppState.self) private var appState
    @State private var onboarding: OnboardingState?
    
    var body: some View {
        NavigationStack {
            if let onboarding {
                content(onboarding)
                    .environment(onboarding)
            }
        }
        .task {
            if onboarding == nil {
                onboarding = OnboardingState(appState: appState)
            }
        }
    }
    
    @ViewBuilder
    private func content(_ onboarding: OnboardingState) -> some View {
        switch onboarding.route {
            case .welcome:
                OnboardingWelcomeView()
                
            case .familyChoice:
                FamilyChoiceView()
                
            case .createFamily:
                CreateFamilyView()
                
            case .joinFamily:
                JoinFamilyView()
                
            case .finished:
                DashboardEntryView()
        }
    }
}


#Preview {
    OnboardingContainerView()
}

