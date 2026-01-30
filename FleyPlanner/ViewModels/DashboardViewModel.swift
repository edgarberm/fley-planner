//
//  DashboardViewModel.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI
import Observation

@Observable
final class DashboardViewModel {
    private let dataService: DataService
    private let currentUserId: UUID
    
    var context: DashboardContext?
    var isLoading = false
    var error: Error?
    
    init(dataService: DataService, currentUserId: UUID) {
        self.dataService = dataService
        self.currentUserId = currentUserId
        print("🟢 DashboardViewModel initialized for user: \(currentUserId)")
    }
    
    @MainActor
    func load() async {
        print("🔵 DashboardViewModel.load() started")
        isLoading = true
        defer {
            isLoading = false
            print("🟡 DashboardViewModel.load() finished, isLoading = false")
        }
        
        do {
            context = try await loadContext()
            print("🟢 Context loaded successfully")
            print("   - Children: \(context?.activeChildren.count ?? 0)")
            print("   - Events: \(context?.upcomingEvents.count ?? 0)")
            print("   - Expenses: \(context?.pendingExpenses.count ?? 0)")
        } catch {
            print("🔴 Error loading context: \(error)")
            self.error = error
        }
    }
    
    private func loadContext() async throws -> DashboardContext {
        print("🔵 Loading context data...")
        
        async let user = dataService.getUser(id: currentUserId)
        async let children = dataService.getChildren(for: currentUserId)
        async let bonds = dataService.getChildBonds(for: currentUserId)
        async let events = dataService.getEvents(for: currentUserId)
        async let expenses = dataService.getExpenses(for: currentUserId)
        async let allUsers = dataService.getAllUsers()
        
        let loadedUser = await user
        let loadedChildren = await children
        let loadedBonds = await bonds
        let loadedEvents = await events
        let loadedExpenses = await expenses
        let loadedAllUsers = await allUsers
        
        print("   - User: \(loadedUser.name)")
        print("   - Children: \(loadedChildren.count)")
        print("   - Bonds: \(loadedBonds.count)")
        print("   - Events: \(loadedEvents.count)")
        print("   - Expenses: \(loadedExpenses.count)")
        print("   - All users: \(loadedAllUsers.count)")
        
        return DashboardContext.generate(
            for: loadedUser,
            children: loadedChildren,
            bonds: loadedBonds,
            events: loadedEvents,
            expenses: loadedExpenses,
            allUsers: loadedAllUsers
        )
    }
}
