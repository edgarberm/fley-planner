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
    private let familyId: UUID
    
    var context: DashboardContext?
    var isLoading = false
    var error: Error?
    
    init(dataService: DataService, currentUser: User, familyId: UUID) {
        self.dataService = dataService
        self.currentUser = currentUser
        self.familyId = familyId
        print("📊 DashboardViewModel created for user: \(currentUser.name)")
    }
    
    deinit {
        print("🗑️ DashboardViewModel deallocated")
    }
    
    @MainActor
    func load() async throws {
        print("🔄 DashboardViewModel.load() started")
        isLoading = true
        defer {
            isLoading = false
            print("✅ DashboardViewModel.load() completed (isLoading = false)")
        }
        
        do {
            context = try await loadContext()
            error = nil
            print("✅ Dashboard context loaded successfully")
        } catch {
            self.error = error
            print("❌ Error loading dashboard context: \(error)")
            throw error
        }
    }
    
    private func loadContext() async throws -> DashboardContext {
        guard !currentUser.id.uuidString.isEmpty else {
            throw DashboardError.invalidUser
        }
        
        print("🔄 Loading dashboard data...")
        print("   User ID: \(currentUser.id)")
        print("   Family ID: \(familyId)")
        
        // Cargar todo en paralelo
        async let children = dataService.getChildren(for: familyId)
        async let members = dataService.getFamilyMembers(familyId: familyId)
        async let bonds = dataService.getChildBonds(for: currentUser.id)
        async let events = dataService.getEvents(for: currentUser.id)
        async let expenses = dataService.getExpenses(for: currentUser.id)
        
        print("⏳ Waiting for all queries to complete...")
        
        let results = await (
            children: children,
            members: members,
            bonds: bonds,
            events: events,
            expenses: expenses
        )
        
        print("✅ All queries completed successfully")
        print("   Children: \(results.children.count)")
        print("   Members: \(results.members.count)")
        print("   Bonds: \(results.bonds.count)")
        print("   Events: \(results.events.count)")
        print("   Expenses: \(results.expenses.count)")
        
        return DashboardContext.generate(
            for: currentUser,
            children: results.children,
            bonds: results.bonds,
            events: results.events,
            expenses: results.expenses,
            allUsers: results.members
        )
    }
    
    @MainActor
    func bindWidgets(_ gridModel: WidgetGridModel) async {
        guard let context else {
            print("⚠️ Cannot bind widgets: context is nil")
            return
        }
        
        // Si necesita onboarding, configurar widgets especiales
        if needsOnboarding {
            print("🎯 Setting up onboarding widgets")
            gridModel.setupOnboardingWidgets()
        } else {
            print("✅ Setting up regular widgets with data")
            gridModel.refreshWidgetViews(context: context)
        }
    }
    
    // MARK: - Onboarding Logic
    
    /// Determina si el usuario necesita ver widgets de onboarding
    var needsOnboarding: Bool {
        guard let context else { return true }
        
        // Si no hay niños, definitivamente necesita onboarding
        if context.activeChildren.isEmpty {
            print("ℹ️ Needs onboarding: no children")
            return true
        }
        
        return false
    }
}
