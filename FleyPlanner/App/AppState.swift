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
    
    /// Nombre que nos da Apple durante el Sign In.
    /// Solo disponible la primera vez que el usuario firma.
    /// Apple NO lo vuelve a dar en sesiones posteriores.
    var appleFullName: String?
    
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
    
    func completeUserBootstrap(onboarding: OnboardingState) async throws {
        guard let authUserId = SupabaseService.shared.client.auth.currentUser?.id else {
            throw AppError.notAuthenticated
        }
        
        guard !onboarding.name.isEmpty else {
            throw AppError.incompleteProfile
        }
        
        let payload = UserBootstrapPayload(
            id: authUserId,
            name: onboarding.name,
            appleId: authUserId.uuidString,
            accountType: onboarding.accountType
        )
        
        try await dataService.upsertUser(payload)
        
        // Guard en vez de force unwrap
        guard let user = await dataService.getUser(id: authUserId) else {
            throw AppError.userNotFound  // ← Añadir este caso a AppError
        }
        
        self.currentUser = user
    }
    
    @MainActor
    func createFamily(name: String) async throws {
        guard let user = currentUser else {
            throw AppError.notAuthenticated
        }

        let familyId = UUID()
        let inviteCode = createfamilyInviteCode(familyId.uuidString)
        
        // 1️⃣ Creamos la familia
        let payload = CreateFamilyPayload(
            id: familyId,
            name: name,
            createdBy: user.id,
            accessMembers: [user.id],  // Lo dejamos por compatibilidad con tu modelo
            inviteCode: inviteCode,
            subscriptionUserId: user.id,
            subscriptionStatus: .active,
            subscriptionStartDate: Date(),
            subscriptionExpiresAt: Calendar.current.date(byAdding: .month, value: 1, to: Date())
        )

        let family = try await dataService.createFamily(payload)
        
        // 2️⃣ Creamos la relación en family_members
        let memberPayload = FamilyMemberInsert(
            familyId: familyId,
            userId: user.id
        )
        try await dataService.addFamilyMember(memberPayload)
        
        self.currentFamily = family
    }

    @MainActor
    func joinFamily(inviteCode: String) async throws {
        guard let user = currentUser else {
            throw AppError.notAuthenticated
        }

        guard let familyId = UUID(uuidString: inviteCode) else {
            throw AppError.invalidInviteCode
        }

        // TODO: review model. userId need to be added to access_members
        let payload = JoinFamilyPayload(
            familyId: familyId,
            userId: user.id
        )

        try await dataService.joinFamily(payload)

        let family = await dataService.getFamily(for: user.id)

        self.currentFamily = family
    }
    
    func completeOnboarding() {
        self.currentRoute = .main
    }
}
