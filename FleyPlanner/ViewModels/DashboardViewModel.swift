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
    }
    
    @MainActor
    func load() async {
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            context = try await loadContext()
        } catch {
            self.error = error
        }
    }
    
    private func loadContext() async throws -> DashboardContext {
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
        
        return DashboardContext.generate(
            for: loadedUser,
            children: loadedChildren,
            bonds: loadedBonds,
            events: loadedEvents,
            expenses: loadedExpenses,
            allUsers: loadedAllUsers
        )
    }
    
    @MainActor
    func bindWidgets(_ gridModel: WidgetGridModel) async {
        guard let context else { return }
        gridModel.refreshWidgetViews(context: context)
    }
}
