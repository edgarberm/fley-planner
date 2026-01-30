//
//  OnboardingContainerView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

struct OnboardingContainerView: View {
    // Accedemos al estado global para leer el usuario cargado
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 20) {
            // Icono de bienvenida
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .padding(.bottom, 10)
            
            // Mensaje personalizado
            if let user = appState.currentUser {
                Text("¡Hola, \(user.name)!")
                    .font(.largeTitle.bold())
                
                Text("Estamos preparando todo para tu familia.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("Cargando tu perfil...")
                    .font(.headline)
            }
            
            Divider()
                .padding(.vertical)
            
            // Botón de ejemplo para mañana
            Button {
                // Aquí llamaremos a la creación de familia mañana
            } label: {
                Text("Crear mi primera familia")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 50)
    }
}

#Preview {
    OnboardingContainerView()
}

