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
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Spacer flexible para centrado vertical
                    Spacer()
                        .frame(minHeight: 40, maxHeight: .infinity)
                        .layoutPriority(-1)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Step 1")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            // ✨ Usando el componente reutilizable
                            AdaptiveTextLayout {
                                Lines {
                                    Line {
                                        Text("Set up your")
                                        Icon("house-heart")
                                        Text("family.")
                                    }
                                    Line {
                                        Icon("calendar-days")
                                        Text("Plan")
                                        Icon("handshake")
                                        Text("share")
                                    }
                                    Line {
                                        Text("and stay in")
                                        Icon("repeat")
                                        Text("sync.")
                                    }
                                }
                            }
                            .frame(height: 120) // Altura fija para consistencia
                        }
                        
                        // Input
                        TextField("Nombre de la familia", text: onboarding.familyNameBinding)
                            .padding(.horizontal, 16)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                            )
                            .font(.title3)
                            .fontWeight(.medium)
                            .submitLabel(.done)
                            .disabled(isLoading)
                        
                        // Continue button
                        Button(action: {
                            Task { await handleCreateFamily() }
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                }
                                Text("Continue")
                            }
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                onboarding.canCreateFamily && !isLoading
                                    ? Color.black
                                    : Color.gray
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .disabled(!onboarding.canCreateFamily || isLoading)
                        
                        // Back button
                        Button(action: {
                            onboarding.route = .welcome
                        }) {
                            Text("Back")
                                .font(.title3.bold())
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 30)
                        }
                        .disabled(isLoading)
                    }
                    .padding(.bottom, 20)
                }
                .frame(minHeight: geometry.size.height)
                .padding(.horizontal, geometry.size.width * 0.06)
            }
            .scrollDisabled(true)
        }
        .alert("Error", isPresented: .constant(currentError != nil)) {
            Button("OK") {
                currentError = nil
            }
        } message: {
            if let error = currentError {
                Text(error.localizedDescription)
            }
        }
    }
    
    private func handleCreateFamily() async {
        isLoading = true
        currentError = nil
        
        do {
            try await appState.createFamily(name: onboarding.familyName)
            appState.completeOnboarding()
        } catch let appErr as AppError {
            currentError = appErr
        } catch {
            print("❌ Error: \(error)")
            currentError = .unknown
        }
        
        isLoading = false
    }
}

#Preview {
    CreateFamilyView()
        .environment(AppState())
        .environment(OnboardingState(appState: AppState()))
}
