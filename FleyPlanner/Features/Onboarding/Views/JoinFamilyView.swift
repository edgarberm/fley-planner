//
//  JoinFamilyView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import SwiftUI

struct JoinFamilyView: View {

    @Environment(AppState.self) private var appState
    @Environment(OnboardingState.self) private var onboarding

    @State private var isLoading = false
    @State private var currentError: AppError?  // ← Renombrado

    var body: some View {
        VStack(spacing: 24) {

            Text("Unirse a una familia")
                .font(.largeTitle.bold())

            TextField("Código de invitación", text: onboarding.inviteCodeBinding)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if let currentError {  // ← Actualizado
                Text(currentError.localizedDescription)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Spacer()

            Button {
                Task {
                    await joinFamily()
                }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Unirme")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(onboarding.inviteCode.isEmpty || isLoading)
        }
        .padding()
    }

    private func joinFamily() async {
        isLoading = true
        currentError = nil

        do {
            try await appState.joinFamily(inviteCode: onboarding.inviteCode)
            appState.completeOnboarding()
        } catch let appErr as AppError {
            currentError = appErr  // ← Actualizado
        } catch {
            currentError = .unknown  // ← Ahora funciona
        }

        isLoading = false
    }
}



#Preview {
    JoinFamilyView()
}
