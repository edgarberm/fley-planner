//
//  SignInView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI
import AuthenticationServices
import Supabase

struct SignInView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("FleyPlanner")
                .font(.largeTitle.bold())
            
            SignInWithAppleButton(.continue) { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                Task {
                    await handleAppleResult(result)
                }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .padding()
        }
    }
    
    private func handleAppleResult(_ result: Result<ASAuthorization, Error>) async {
        switch result {
            case .success(let auth):
                guard let appleCredential = auth.credential as? ASAuthorizationAppleIDCredential,
                      let idToken = appleCredential.identityToken.flatMap({ String(data: $0, encoding: .utf8) }) else { return }
                
                do {
                    // 1. Auth puro
                    let userId = try await appState.dataService.signInWithApple(idToken: idToken, nonce: nil)
                    
                    // 2. Intentamos ver si ya existe para no machacar el nombre con "Nuevo Usuario"
                    let existingUser = await appState.dataService.getUser(id: userId)
                    
                    if let existingUser {
                        // El usuario ya existe, lo cargamos y vamos a Main o Onboarding
                        await appState.completeRegistration(user: existingUser)
                    } else {
                        // Es NUEVO: Capturamos lo que Apple nos dé ahora o nunca
                        let fullName = appleCredential.fullName
                        let name = [fullName?.givenName, fullName?.familyName]
                            .compactMap { $0 }
                            .joined(separator: " ")
                        
                        // Guardamos el nombre en AppState antes de avanzar
                        appState.appleFullName = name.isEmpty ? nil : name
                        
                        let newUser = User(
                            id: userId,
                            name: name.isEmpty ? "New User" : name,
                            email: appleCredential.email,
                            appleId: appleCredential.user,
                            accountType: .adult,
                            isPremium: false,
                            notificationSettings: .default
                        )
                        
                        await appState.completeRegistration(user: newUser)
                    }
                    
                } catch {
                    print("❌ Error en el flujo de entrada: \(error)")
                }
                
            case .failure(let error):
                print("❌ Apple Error: \(error.localizedDescription)")
        }
    }
}
