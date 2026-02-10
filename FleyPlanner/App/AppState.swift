//
//  AppState.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI
import Observation
import AuthenticationServices

@Observable
final class AppState {
    enum AppRoute {
        case splash      // Comprobando sesión
        case auth        // Sign In with Apple
        case onboarding  // Crear/Unirse a familia
        case main        // Dashboard
    }
    
    // MARK: - State
    
    var currentRoute: AppRoute = .splash
    var currentUser: User?
    var currentFamily: Family?
    
    /// Nombre de Apple (solo disponible en primer sign-in)
    var appleFullName: String?
    
    private(set) var dataService: DataService
    
    // MARK: - Initialization
    
    init(dataService: DataService = SupabaseService.shared) {
        self.dataService = dataService
    }
    
    // MARK: - Session Management
    
    @MainActor
    func initializeSession() async {
        guard let authUserId = SupabaseService.shared.client.auth.currentUser?.id else {
            currentRoute = .auth
            return
        }
        
        async let user = dataService.getUser(id: authUserId)
        async let family = dataService.getFamily(for: authUserId)
        
        let (loadedUser, loadedFamily) = await (user, family)
        
        // Routing logic
        switch (loadedUser, loadedFamily) {
            case (.some(let user), .some(let family)):
                self.currentUser = user
                self.currentFamily = family
                self.currentRoute = .main
                
            case (.some(let user), .none):
                self.currentUser = user
                self.currentRoute = .onboarding
                
            case (.none, _):
                self.currentRoute = .onboarding
        }
    }
    
    // MARK: - Sign In
    
    @MainActor
    func signInWithApple(credential: ASAuthorizationAppleIDCredential, idToken: String) async throws {
        print("🔐 Starting Apple Sign In...")
        
        // 1. Auth en Supabase
        let userId = try await dataService.signInWithApple(
            idToken: idToken,
            nonce: nil
        )
        print("✅ Authenticated with Supabase. User ID: \(userId)")
        
        // 2. Verificar si el usuario ya existe en nuestra DB
        if let existingUser = await dataService.getUser(id: userId) {
            print("✅ Existing user found: \(existingUser.name)")
            
            self.currentUser = existingUser
            
            let family = await dataService.getFamily(for: userId)
            if let family = family {
                self.currentFamily = family
                self.currentRoute = .main
                print("✅ User has family, going to main")
            } else {
                self.currentRoute = .onboarding
                print("⚠️ User has no family, going to onboarding")
            }
        } else {
            print("👤 New user detected (no profile in DB)")
            
            // Usuario nuevo → guardar nombre de Apple
            let fullName = credential.fullName
            let name = [fullName?.givenName, fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            print("📝 Name from Apple: '\(name.isEmpty ? "empty" : name)'")
            self.appleFullName = name.isEmpty ? nil : name
            
            // Crear usuario básico usando UserBootstrapPayload (que sí funciona)
            let payload = UserBootstrapPayload(
                id: userId,
                name: name.isEmpty ? "New User" : name,
                appleId: credential.user,
                accountType: .adult
            )
            
            print("💾 Saving new user to DB...")
            try await dataService.upsertUser(payload)
            
            // Cargar el usuario recién creado
            guard let newUser = await dataService.getUser(id: userId) else {
                print("❌ Failed to load newly created user")
                throw AppError.userNotFound
            }
            
            print("✅ User created and loaded: \(newUser.name)")
            
            self.currentUser = newUser
            self.currentRoute = .onboarding
        }
    }
    
    @MainActor
    func signOut() async throws {
        try await SupabaseService.shared.client.auth.signOut()
        currentUser = nil
        currentFamily = nil
        appleFullName = nil
        currentRoute = .auth
    }
    
    // MARK: - User Bootstrap
    
    @MainActor
    func completeUserBootstrap(onboarding: OnboardingState) async throws {
        guard let authUserId = SupabaseService.shared.client.auth.currentUser?.id else {
            throw AppError.notAuthenticated
        }
        
        let payload = UserBootstrapPayload(
            id: authUserId,
            name: onboarding.name,
            appleId: authUserId.uuidString,
            accountType: onboarding.accountType
        )
        
        try await dataService.upsertUser(payload)
        
        guard let user = await dataService.getUser(id: authUserId) else {
            throw AppError.userNotFound
        }
        
        self.currentUser = user
    }
    
    @MainActor
    func completeOnboarding() {
        currentRoute = .main
    }
    
    // MARK: - Family Management
    
    @MainActor
    func createFamily(name: String) async throws {
        guard let user = currentUser else {
            throw AppError.notAuthenticated
        }
        
        let familyId = UUID()
        let inviteCode = createfamilyInviteCode(familyId.uuidString)
        
        let payload = CreateFamilyPayload(
            id: familyId,
            name: name,
            createdBy: user.id,
            accessMembers: [user.id],
            inviteCode: inviteCode,
            subscriptionUserId: user.id,
            subscriptionStatus: .active,
            subscriptionStartDate: Date(),
            subscriptionExpiresAt: Calendar.current
                .date(byAdding: .month, value: 1, to: Date())
        )
        
        let family = try await dataService.createFamily(payload)
        
        let memberPayload = FamilyMemberInsert(
            familyId: familyId,
            userId: user.id
        )
        try await dataService.addFamilyMember(memberPayload)
        
        self.currentFamily = family
            
        // ✅ Crear widgets por defecto
        let defaultWidgets = [
            DashboardWidgetConfig(userId: user.id, kind: .today, size: .wide, position: 0),
            DashboardWidgetConfig(userId: user.id, kind: .calendar, size: .small, position: 1),
            DashboardWidgetConfig(userId: user.id, kind: .children, size: .small, position: 2)
        ]
        
        try await dataService.saveWidgetConfigs(defaultWidgets)
        print("✅ Default widgets created")
    }
    
    @MainActor
    func joinFamily(inviteCode: String) async throws {
        guard let user = currentUser else {
            throw AppError.notAuthenticated
        }
        
        guard let familyId = UUID(uuidString: inviteCode) else {
            throw AppError.invalidInviteCode
        }
        
        let payload = JoinFamilyPayload(
            familyId: familyId,
            userId: user.id
        )
        
        try await dataService.joinFamily(payload)
        
        let family = await dataService.getFamily(for: user.id)
        self.currentFamily = family
    }
}
