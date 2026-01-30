//
//  MockDataService.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import Foundation

// Cuando empecemos a mutar cosas hay que usar `actor`
final class MockDataService: DataService {
    static let shared = MockDataService()
    
    private let mockData = MockData.shared
    
    func getUser(id: UUID) async -> User {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        
        // Solo para el mock. Después:
        // func getUser(id: UUID) async throws -> User
        guard let user = mockData.allUsers.first(where: { $0.id == id }) else {
            fatalError("User not found in MockData")
        }
        return user
    }
    
    func getAllUsers() async -> [User] {
        try? await Task.sleep(nanoseconds: 300_000_000)
        return mockData.allUsers
    }
    
    func getChildren(for userId: UUID) async -> [Child] {
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Get child IDs this user has bonds with
        let bondedChildIds = mockData.childBonds
            .filter { $0.userId == userId }
            .map { $0.childId }
        
        // Also check ChildLinks for teens
        let linkedChildIds = mockData.childLinks
            .filter { $0.userId == userId }
            .map { $0.childId }
        
        let allChildIds = Set(bondedChildIds + linkedChildIds)
        
        return mockData.allChildren.filter { allChildIds.contains($0.id) }
    }
    
    func getChildBonds(for userId: UUID) async -> [ChildBond] {
        try? await Task.sleep(nanoseconds: 300_000_000)
        return mockData.childBonds.filter { $0.userId == userId }
    }
    
    func getEvents(for userId: UUID) async -> [CalendarEvent] {
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Get children this user has access to
        let children = await getChildren(for: userId)
        let childIds = children.map { $0.id }
        
        return mockData.events.filter { childIds.contains($0.childId) }
    }
    
    func getExpenses(for userId: UUID) async -> [Expense] {
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Get children this user has access to
        let children = await getChildren(for: userId)
        let childIds = children.map { $0.id }
        
        return mockData.expenses.filter { childIds.contains($0.childId) }
    }
    
    func getCareItems(for userId: UUID) async -> [CareItem] {
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        let children = await getChildren(for: userId)
        let childIds = children.map { $0.id }
        
        return mockData.careItems.filter { childIds.contains($0.childId) }
    }
}
