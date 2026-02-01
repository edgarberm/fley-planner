//
//  CreateFamilyView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import SwiftUI

struct CreateFamilyView: View {
    @Environment(AppState.self) private var appState
    @Environment(OnboardingState.self) private var onboarding
    
    @State private var isLoading = false
    @State private var currentError: AppError?
    
    var body: some View {
        VStack(spacing: 24) {
            
            Text("Nueva familia")
                .font(.largeTitle.bold())

            TextField("Nombre de la familia", text: onboarding.familyNameBinding)
                .textFieldStyle(.roundedBorder)
                .disabled(isLoading)

            if let currentError {
                Text(currentError.localizedDescription)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Spacer()

            Button("Crear familia") {
                Task { await handleCreateFamily() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(onboarding.familyName.isEmpty || isLoading)
            
            if isLoading {
                ProgressView()
            }
        }
        .padding()
    }
    
    private func handleCreateFamily() async {
        isLoading = true
        currentError = nil
        
        do {
            try await appState.createFamily(name: onboarding.familyName)
            // Solo navegar DESPUÉS de que todo termine exitosamente
            appState.completeOnboarding()
        } catch let appErr as AppError {
            currentError = appErr
        } catch {
            print("❌ Error real: \(error)")
            print("❌ Tipo: \(type(of: error))")
            currentError = .unknown
        }
        
        isLoading = false
    }
}

#Preview {
    CreateFamilyView()
}
