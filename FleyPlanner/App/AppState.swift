//
//  AppState.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI
import Observation

@Observable
final class AppState {
    enum AppRoute {
        case splash      // Comprobando sesión
        case auth        // Sign In with Apple
        case onboarding  // Registro inicial / Crear Familia
        case main        // Dashboard
    }
    
    var currentRoute: AppRoute = .splash
    var currentUser: User?
    var currentFamily: Family?
    
    private(set) var dataService: DataService
    
    init(dataService: DataService = SupabaseService.shared) {
        self.dataService = dataService
    }
    
    @MainActor
    func initializeSession() async {
        // 1. Obtenemos el ID de Supabase Auth
        guard let authUserId = SupabaseService.shared.client.auth.currentUser?.id else {
            currentRoute = .auth
            return
        }
        
        // 2. Cargamos datos (sin try, porque no lanzan errores)
        let userId = authUserId
        async let user = dataService.getUser(id: userId)
        async let family = dataService.getFamily(for: userId)
        
        let (loadedUser, loadedFamily) = await (user, family)
        
        // 3. Decidimos la ruta
        if let user = loadedUser, let family = loadedFamily {
            self.currentUser = user
            self.currentFamily = family
            self.currentRoute = .main
        } else if let user = loadedUser {
            self.currentUser = user
            self.currentRoute = .onboarding
        } else {
            // Auth existe pero no hay perfil en la tabla 'profiles'
            self.currentRoute = .onboarding
        }
    }
    
    @MainActor
    func completeRegistration(user: User) async {
        do {
            // Guardamos en la base de datos
            try await SupabaseService.shared.client
                .from("users") // Asegúrate de que la tabla se llama 'users'
                .upsert(user)
                .execute()
            
            self.currentUser = user
            
            // Verificamos si ya tiene familia para saber a dónde mandarlo
            let family = await dataService.getFamily(for: user.id)
            
            if let family = family {
                self.currentFamily = family
                self.currentRoute = .main
            } else {
                self.currentRoute = .onboarding
            }
        } catch {
            print("❌ Error guardando perfil: \(error)")
        }
    }
}


//
//@Observable
//final class AppState {
//    var currentUser: User?
//    private(set) var dataService: DataService
//
//    init(dataService: DataService = MockDataService.shared) {
//        self.dataService = dataService
//        print("🟢 AppState initialized")
//    }
//
//    var isAuthenticated: Bool {
//        currentUser != nil
//    }
//
//    func signIn(userId: UUID) async {
//        print("🔵 Signing in user: \(userId)")
//        currentUser = await dataService.getUser(id: userId)
//        print("🟢 Signed in as: \(currentUser?.name ?? "nil")")
//    }
//
//    func signOut() {
//        print("🔴 Signing out")
//        currentUser = nil
//    }
//}
