//
//  DataService.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import Foundation

protocol DataService {
    // Auth
    func signInWithApple(idToken: String, nonce: String?) async throws -> UUID
    func saveUser(_ user: User) async throws
    
    func getUser(id: UUID) async -> User?
    func getFamily(for userId: UUID) async -> Family?
    func getFamilyMembers(familyId: UUID) async -> [User]
    func getChildren(for userId: UUID) async -> [Child]
    func getChildBonds(for userId: UUID) async -> [ChildBond]
    func getEvents(for userId: UUID) async -> [CalendarEvent]
    func getExpenses(for userId: UUID) async -> [Expense]
    func getCareItems(for userId: UUID) async -> [CareItem]
}
