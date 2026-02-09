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
    private let currentUser: User
    private let family: Family
    
    var context: DashboardContext?
    var isLoading = false
    var error: Error?
    
    init(dataService: DataService, currentUser: User, family: Family) {
        self.dataService = dataService
        self.currentUser = currentUser
        self.family = family
    }
    
    // MARK: - Load Data
    
    @MainActor
    func load() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            context = try await loadContext()
            error = nil
        } catch {
            self.error = error
            throw error
        }
    }
    
    private func loadContext() async throws -> DashboardContext {
        guard !currentUser.id.uuidString.isEmpty else {
            throw DashboardError.invalidUser
        }
        
        // Carga paralela de todos los datos
        async let children = dataService.getChildren(for: family.id)
        async let members = dataService.getFamilyMembers(familyId: family.id)
        async let bonds = dataService.getChildBonds(for: currentUser.id)
        async let events = dataService.getEvents(for: currentUser.id)
        async let expenses = dataService.getExpenses(for: currentUser.id)
        
        let (loadedChildren, loadedMembers, loadedBonds, loadedEvents, loadedExpenses) =
            await (children, members, bonds, events, expenses)
        
        return DashboardContext.generate(
            for: currentUser,
            children: loadedChildren,
            bonds: loadedBonds,
            events: loadedEvents,
            expenses: loadedExpenses,
            allUsers: loadedMembers
        )
    }
    
    // MARK: - Refresh
    
    @MainActor
    func refresh() async {
        do {
            try await load()
        } catch {
            // Error ya está en self.error
        }
    }
}
