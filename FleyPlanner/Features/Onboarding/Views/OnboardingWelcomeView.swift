//
//  OnboardingWelcomeView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import SwiftUI

struct OnboardingWelcomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(OnboardingState.self) private var onboarding
    
    @State private var isLoading = false
    @State private var currentError: AppError?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(minHeight: 40, maxHeight: .infinity)
                    .layoutPriority(-1)
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Welcome \(onboarding.name.split(separator: " ").first ?? "Edgar")!")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        AdaptiveTextLayout {
                            Lines {
                                Line {
                                    Text("Choose your")
                                    Icon("circle-user")
                                    Text("role")
                                }
                                Line {
                                    Text("and start")
                                    Icon("layout-dashboard")
                                    Text("planning")
                                }
                                Line {
                                    Icon("users")
                                    Text("together")
                                }
                            }
                        }
                        .frame(height: 108)
                    }
                    
                    SelectableCard(
                        title: "Adult",
                        description: "Manage and coordinate family.",
                        isSelected: onboarding.accountTypeBinding.wrappedValue == .adult
                    ) {
                        onboarding.accountTypeBinding.wrappedValue = .adult
                    }
                    
                    SelectableCard(
                        title: "Child",
                        description: "Be part of the family plan.",
                        isSelected: onboarding.accountTypeBinding.wrappedValue == .children
                    ) {
                        onboarding.accountTypeBinding.wrappedValue = .children
                    }
                    
                    Button(action: {
                        Task {
                            await handleContinue(to: onboarding.accountTypeBinding.wrappedValue == .adult ? .createFamily : .joinFamily)
                        }
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
                            onboarding.accountTypeBinding.wrappedValue != nil && !isLoading
                                ? Color.black
                                : Color.gray
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .disabled(onboarding.accountTypeBinding.wrappedValue == nil || isLoading)
                }
                
            }
            .frame(minHeight: geometry.size.height)
            .padding(.horizontal, geometry.size.width * 0.06)
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
    
    private func handleContinue(to route: OnboardingRoute) async {
        isLoading = true
        currentError = nil
        
        do {
            try await appState.completeUserBootstrap(onboarding: onboarding)
            onboarding.route = route
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

struct SelectableCard: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .black : .secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.black : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain) // 🔑 evita el highlight azul
    }
}


#Preview {
    OnboardingWelcomeView()
        .environment(AppState())
        .environment(OnboardingState(appState: AppState()))
}
