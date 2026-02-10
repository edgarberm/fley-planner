//
//  DataService.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import Foundation

protocol DataService {
    // MARK: - Auth
    func signInWithApple(idToken: String, nonce: String?) async throws -> UUID
    func saveUser(_ user: User) async throws
    
    // MARK: - User
    func getUser(id: UUID) async -> User?
    func upsertUser(_ user: UserBootstrapPayload) async throws
    
    // MARK: - Family
    func getFamily(for userId: UUID) async -> Family?
    func getFamilyMembers(familyId: UUID) async -> [User]
    func createFamily(_ payload: CreateFamilyPayload) async throws -> Family?
    func joinFamily(_ payload: JoinFamilyPayload) async throws
    func addFamilyMember(_ payload: FamilyMemberInsert) async throws
    func updateFamily(_ family: Family) async throws
    
    // MARK: - Children & Related Data
    func getChildren(for familyId: UUID) async -> [Child]
    /// Crea un nuevo child en la base de datos
    func createChild(_ payload: CreateChildPayload) async throws -> Child
    
    /// Obtiene los bonds (relaciones) entre el usuario y los niños
    func getChildBonds(for userId: UUID) async -> [ChildBond]
    /// Crea un vínculo entre un adulto y un child
    func createChildBond(_ payload: CreateChildBondPayload) async throws -> ChildBond

    /// Obtiene eventos relacionados con los niños del usuario
    func getEvents(for userId: UUID) async -> [CalendarEvent]
    
    /// Obtiene gastos relacionados con los niños del usuario
    func getExpenses(for userId: UUID) async -> [Expense]
    
    /// Obtiene tareas/recordatorios relacionados con los niños del usuario
    func getCareItems(for userId: UUID) async -> [CareItem]
}

