//
//  SupabaseService.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import Foundation
import Supabase
import Auth

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
    
    func signInWithApple(idToken: String, nonce: String? = nil) async throws -> UUID {
        let response = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        return response.user.id
    }

    func saveUser(_ user: User) async throws {
        try await client
            .from("users") // Tu tabla en Supabase
            .upsert(user)
            .execute()
    }
    
    func getUser(id: UUID) async -> User? {
        do {
            return try await client.from("users")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
        } catch {
            // Solo imprimimos si el error NO es que no existe el registro
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
    }
    
    func getFamily(for userId: UUID) async -> Family? {
        do {
            return try await client
                .from("families")
                .select()
            // Buscamos si el userId está dentro del array access_members de Postgres
                .contains("access_members", value: [userId])
                .single()
                .execute()
                .value
        } catch {
            print("⚠️ No family found for user: \(error)")
            return nil
        }
    }
    
    func getFamilyMembers(familyId: UUID) async -> [User] {
        return []
    }
    
    func createFamily(_ payload: CreateFamilyPayload) async throws -> Family? {
        do {
            return try await client
                .from("families")
                .insert(payload)
                .select()
                .single()
                .execute()
                .value
        } catch {
            print("⚠️ No family created for user: \(error)")
            return nil
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
    }

    func addFamilyMember(_ payload: FamilyMemberInsert) async throws {
        try await client
            .from("family_members")
            .insert(payload)
            .execute()
    }
    
    func getChildren(for userId: UUID) async -> [Child] {
        do {
            return try await client.from("children")
                .select()
                .eq("id", value: userId)
            //.single()
                .execute()
                .value
        } catch {
            print("❌ Error fetching user: \(error)")
            return []
        }
    }
    
    func getChildBonds(for userId: UUID) async -> [ChildBond] {
        do {
            return try await client.from("child_bonds")
                .select()
                .eq("id", value: userId)
            //.single()
                .execute()
                .value
        } catch {
            print("❌ Error fetching user: \(error)")
            return []
        }
    }
    
    func getEvents(for userId: UUID) async -> [CalendarEvent] {
        do {
            return try await client.from("events")
                .select()
                .eq("id", value: userId)
            //.single()
                .execute()
                .value
        } catch {
            print("❌ Error fetching user: \(error)")
            return []
        }
    }
    
    func getExpenses(for userId: UUID) async -> [Expense] {
        do {
            return try await client.from("expenses")
                .select()
                .eq("id", value: userId)
            //.single()
                .execute()
                .value
        } catch {
            print("❌ Error fetching user: \(error)")
            return []
        }
    }
    
    func getCareItems(for userId: UUID) async -> [CareItem] {
        do {
            return try await client.from("care_items")
                .select()
                .eq("id", value: userId)
            //.single()
                .execute()
                .value
        } catch {
            print("❌ Error fetching user: \(error)")
            return []
        }
    }
}
