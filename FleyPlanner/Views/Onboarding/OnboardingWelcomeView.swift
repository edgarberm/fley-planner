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
        VStack(spacing: 24) {

            Text("Bienvenido")
                .font(.largeTitle.bold())

            if onboarding.name.isEmpty {
                TextField("Tu nombre", text: onboarding.nameBinding)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isLoading)
            } else {
                Text("Hola, \(onboarding.name)")
                    .font(.title2)
            }

            Picker("Tipo de cuenta", selection: onboarding.accountTypeBinding) {
                Text("Adulto").tag(AccountType.adult)
                Text("Niño/a").tag(AccountType.children)
            }
            .pickerStyle(.segmented)
            .disabled(isLoading)

            if let currentError {
                Text(currentError.localizedDescription)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Spacer()

            HStack(spacing: 16) {
                Button("Crear familia") {
                    Task { await handleContinue(to: .createFamily) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(onboarding.name.isEmpty || isLoading)

                Button("Unirme a familia") {
                    Task { await handleContinue(to: .joinFamily) }
                }
                .buttonStyle(.bordered)
                .disabled(onboarding.name.isEmpty || isLoading)
            }

            if isLoading {
                ProgressView()
            }
        }
        .padding()
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
            print("❌ Error real: \(error)")           // ← Añade esto
            print("❌ Tipo: \(type(of: error))")       // ← Y esto
            currentError = .unknown
        }

        isLoading = false
    }
}

#Preview {
    OnboardingWelcomeView()
}
