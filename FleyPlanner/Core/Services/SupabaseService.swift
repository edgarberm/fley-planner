//
//  SupabaseService.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import Foundation
import Supabase

final class SupabaseService: DataService {
    static let shared = SupabaseService()
    let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://cxdffpgxmddjymmxdlzi.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN4ZGZmcGd4bWRkanltbXhkbHppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk3ODc1OTMsImV4cCI6MjA4NTM2MzU5M30.1HOvuBOQDeaoKHHIdYBhJ4cx-Al_Gkmfv8mM8uvulic",
            options: .init(auth: .init(emitLocalSessionAsInitialSession: true))
        )
    }
    
    // MARK: - Auth
    
    func signInWithApple(idToken: String, nonce: String? = nil) async throws -> UUID {
        let response = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        return response.user.id
    }
    
    func saveUser(_ user: User) async throws {
        try await client
            .from("users")
            .upsert(user)
            .execute()
    }
    
    // MARK: - User
    
    func getUser(id: UUID) async -> User? {
        do {
            let user: User = try await client
                .from("users")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            
            print("✅ User loaded: \(user.name)")
            return user
            
        } catch {
            if let pgError = error as? PostgrestError, pgError.code == "PGRST116" {
                print("👤 Usuario nuevo detectado (sin perfil en DB)")
            } else {
                print("❌ Error real recuperando usuario: \(error)")
            }
            return nil
        }
    }
    
    func upsertUser(_ user: UserBootstrapPayload) async throws {
        try await client
            .from("users")
            .upsert(user)
            .execute()
        
        print("✅ User upserted")
    }
    
    // MARK: - Family
    
    func getFamily(for userId: UUID) async -> Family? {
        do {
            // 1. Buscar en family_members
            struct FamilyMemberRow: Decodable {
                let family_id: UUID
            }
            
            let memberRow: FamilyMemberRow = try await client
                .from("family_members")
                .select("family_id")
                .eq("user_id", value: userId)  // ← Busca correctamente
                .single()
                .execute()
                .value
            
            print("✅ Found family_id: \(memberRow.family_id)")
            
            // 2. Obtener la familia completa
            let family: Family = try await client
                .from("families")
                .select()
                .eq("id", value: memberRow.family_id)
                .single()
                .execute()
                .value
            
            print("✅ Family loaded: \(family.name)")
            return family
            
        } catch {
            if let pgError = error as? PostgrestError, pgError.code == "PGRST116" {
                print("⚠️ No family found for user (expected for new users)")
            } else {
                print("❌ Error fetching family: \(error)")
            }
            return nil
        }
    }
    
    func getFamilyMembers(familyId: UUID) async -> [User] {
        do {
            // 1. Obtener user_ids de family_members
            struct MemberRow: Decodable {
                let user_id: UUID
            }
            
            let memberRows: [MemberRow] = try await client
                .from("family_members")
                .select("user_id")
                .eq("family_id", value: familyId)
                .execute()
                .value
            
            let userIds = memberRows.map { $0.user_id }
            
            guard !userIds.isEmpty else {
                print("⚠️ No members found for family")
                return []
            }
            
            print("✅ Found \(userIds.count) member(s) for family")
            
            // 2. Obtener usuarios completos
            let users: [User] = try await client
                .from("users")
                .select()
                .in("id", values: userIds)
                .execute()
                .value
            
            print("✅ Family members loaded: \(users.count)")
            return users
            
        } catch {
            print("❌ Error fetching family members: \(error)")
            return []
        }
    }
    
    func createFamily(_ payload: CreateFamilyPayload) async throws -> Family? {
        do {
            let family: Family = try await client
                .from("families")
                .insert(payload)
                .select()
                .single()
                .execute()
                .value
            
            print("✅ Family created: \(family.name)")
            return family
            
        } catch {
            print("❌ Error creating family: \(error)")
            throw error
        }
    }
    
    func joinFamily(_ payload: JoinFamilyPayload) async throws {
        let insert = FamilyMemberInsert(
            familyId: payload.familyId,
            userId: payload.userId
        )
        
        try await client
            .from("family_members")
            .insert(insert)
            .execute()
        
        print("✅ User joined family")
    }
    
    func addFamilyMember(_ payload: FamilyMemberInsert) async throws {
        try await client
            .from("family_members")
            .insert(payload)
            .execute()
        
        print("✅ Family member added")
    }
    
    func updateFamily(_ family: Family) async throws {
        try await client
            .from("families")
            .update(family)
            .eq("id", value: family.id.uuidString)
            .execute()
    }
    
    // MARK: - Children & Related Data
    
    func getChildren(for familyId: UUID) async -> [Child] {
        do {
            let children: [Child] = try await client
                .from("children")
                .select()
                .eq("family_id", value: familyId)
                .execute()
                .value
            
            print("✅ Children loaded: \(children.count)")
            return children
            
        } catch {
            print("❌ Error fetching children: \(error)")
            return []
        }
    }
    
    func createChild(_ payload: CreateChildPayload) async throws -> Child {
        print("💾 Creating child: \(payload.name)")
        // ✅ INSERT sin .select()
        try await client
            .from("children")
            .insert(payload)
            .execute()
        
        print("✅ Child inserted (without select)")
        
        // ✅ Construir el Child manualmente desde el payload
        let child = Child(
            id: payload.id,
            familyId: payload.familyId,
            name: payload.name,
            birthDate: payload.birthDate ?? Date(),  // Ajusta según tu lógica
            avatarURL: payload.avatarURL ?? nil,
            custodyConfig: payload.custodyConfig ?? nil,
            medicalInfo: payload.medicalInfo ?? nil
        )
        
        return child
    }
    
    func getChildBonds(for userId: UUID) async -> [ChildBond] {
        do {
            let bonds: [ChildBond] = try await client
                .from("child_bonds")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            
            print("✅ Child bonds loaded: \(bonds.count)")
            return bonds
            
        } catch {
            print("❌ Error fetching child bonds: \(error)")
            return []
        }
    }
    
    func createChildBond(_ payload: CreateChildBondPayload) async throws -> ChildBond {
        print("💾 Creating child bond for user \(payload.userId)")
        
        // ✅ INSERT sin .select()
        try await client
            .from("child_bonds")
            .insert(payload)
            .execute()
        
        print("✅ Child bond inserted (without select)")
        
        // ✅ Construir el ChildBond manualmente desde el payload
        let bond = ChildBond(
            id: payload.id,
            childId: payload.childId,
            userId: payload.userId,
            role: payload.role,
            relationship: payload.relationship,
            permissions: payload.permissions,
            status: payload.status,
            expenseContribution: payload.expenseContribution
        )
        
        return bond
    }
    
    func getEvents(for userId: UUID) async -> [Activity] {
        do {
            // Primero obtenemos los bonds para saber qué children tiene el usuario
            let bonds = await getChildBonds(for: userId)
            let childIds = bonds.map { $0.childId }
            
            guard !childIds.isEmpty else {
                print("⚠️ No children found for user, returning empty events")
                return []
            }
            
            let events: [Activity] = try await client
                .from("events")
                .select()
                .in("child_id", values: childIds)
                .execute()
                .value
            
            print("✅ Events loaded: \(events.count)")
            return events
            
        } catch {
            print("❌ Error fetching events: \(error)")
            return []
        }
    }
    
    func getExpenses(for userId: UUID) async -> [Expense] {
        do {
            let bonds = await getChildBonds(for: userId)
            let childIds = bonds.map { $0.childId }
            
            guard !childIds.isEmpty else {
                print("⚠️ No children found for user, returning empty expenses")
                return []
            }
            
            let expenses: [Expense] = try await client
                .from("expenses")
                .select()
                .in("child_id", values: childIds)
                .execute()
                .value
            
            print("✅ Expenses loaded: \(expenses.count)")
            return expenses
            
        } catch {
            print("❌ Error fetching expenses: \(error)")
            return []
        }
    }
    
    func getCareItems(for userId: UUID) async -> [CareItem] {
        do {
            let bonds = await getChildBonds(for: userId)
            let childIds = bonds.map { $0.childId }
            
            guard !childIds.isEmpty else {
                print("⚠️ No children found for user, returning empty care items")
                return []
            }
            
            let items: [CareItem] = try await client
                .from("care_items")
                .select()
                .in("child_id", values: childIds)
                .execute()
                .value
            
            print("✅ Care items loaded: \(items.count)")
            return items
            
        } catch {
            print("❌ Error fetching care items: \(error)")
            return []
        }
    }
    
    // MARK: - Dashboard Widgets
    
    func getWidgetConfigs(for userId: UUID) async throws -> [DashboardWidgetConfig] {
        let response = try await client
            .from("dashboard_widgets")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("position")
            .execute()
        
        // ✅ Configurar decoder para fechas ISO8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let configs = try decoder.decode([DashboardWidgetConfig].self, from: response.data)
        print("✅ Loaded \(configs.count) widget configs")
        return configs
    }
    
    func saveWidgetConfigs(_ configs: [DashboardWidgetConfig]) async throws {
        print("💾 Saving \(configs.count) widget configs...")
        
        // Actualizar updatedAt y positions
        let updatedConfigs = configs.enumerated().map { index, config in
            var updated = config
            updated.position = index
            updated.updatedAt = Date()
            return updated
        }
        
        // ✅ Configurar encoder para fechas ISO8601
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        //let data = try encoder.encode(updatedConfigs)
        
        // Upsert con data pre-encoded
        try await client
            .from("dashboard_widgets")
            .upsert(updatedConfigs)  // Supabase-swift maneja esto automáticamente
            .execute()
        
        print("✅ Widget configs saved")
    }
}
