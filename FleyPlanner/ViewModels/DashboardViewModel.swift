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
    private let currentUser: User        // ← Cambio: recibe User, no UUID
    private let familyId: UUID           // ← Cambio: recibe familyId directamente
    
    var context: DashboardContext?
    var isLoading = false
    var error: Error?
    
    init(dataService: DataService, currentUser: User, familyId: UUID) {
        self.dataService = dataService
        self.currentUser = currentUser
        self.familyId = familyId
    }
    
    @MainActor
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            context = try await loadContext()
        } catch {
            self.error = error
        }
    }
    
    private func loadContext() async throws -> DashboardContext {
        // Todo en paralelo, sin necesidad de llamadas secuenciales
        async let children = dataService.getChildren(for: familyId)
        async let members = dataService.getFamilyMembers(familyId: familyId)
        async let bonds = dataService.getChildBonds(for: currentUser.id)
        async let events = dataService.getEvents(for: currentUser.id)
        async let expenses = dataService.getExpenses(for: currentUser.id)
        
        let (loadedChildren, loadedMembers, loadedBonds, loadedEvents, loadedExpenses) =
            await (children, members, bonds, events, expenses)
        
        return DashboardContext.generate(
            for: currentUser,                // ← Usa el user que ya tenemos
            children: loadedChildren,
            bonds: loadedBonds,
            events: loadedEvents,
            expenses: loadedExpenses,
            allUsers: loadedMembers
        )
    }
    
    @MainActor
    func bindWidgets(_ gridModel: WidgetGridModel) async {
        guard let context else { return }
        gridModel.refreshWidgetViews(context: context)
    }
}
