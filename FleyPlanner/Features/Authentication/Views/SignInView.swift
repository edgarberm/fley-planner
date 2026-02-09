//
//  SignInView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AppState.self) private var appState
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Logo/Title
            VStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                
                Text("FleyPlanner")
                    .font(.largeTitle.bold())
                
                Text("Organize your family life")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Error message
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Sign In Button
            if isLoading {
                ProgressView()
                    .frame(height: 60)
            } else {
                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                    Task {
                        await handleAppleResult(result)
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
    
    private func handleAppleResult(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let idToken = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8) })
            else {
                errorMessage = "Invalid Apple credential"
                return
            }
            
            do {
                try await appState.signInWithApple(credential: credential, idToken: idToken)
            } catch {
                errorMessage = "Sign in failed: \(error.localizedDescription)"
            }
            
        case .failure(let error):
            if let authError = error as? ASAuthorizationError,
               authError.code == .canceled {
                // Usuario canceló, no mostrar error
                return
            }
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
    }
}

#Preview {
    SignInView()
        .environment(AppState())
}
