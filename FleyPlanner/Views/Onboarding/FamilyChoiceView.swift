//
//  FamilyChoiceView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import SwiftUI

struct FamilyChoiceView: View {
    
    @Environment(OnboardingState.self) private var onboarding
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 32) {
            
            Text("Tu familia")
                .font(.largeTitle.bold())

            VStack(spacing: 16) {
                Button("Crear una familia") {
                    onboarding.route = .createFamily
                }
                .buttonStyle(.borderedProminent)

                Button("Unirme a una familia") {
                    onboarding.route = .joinFamily
                }
                .buttonStyle(.bordered)

                Button("Lo haré más tarde") {
                    appState.completeOnboarding()
                }
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
    }
}


#Preview {
    FamilyChoiceView()
}
