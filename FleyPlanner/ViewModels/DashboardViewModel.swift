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
        // 1. Cargamos al usuario actual
        guard let loadedUser = await dataService.getUser(id: currentUserId) else {
            throw DataError.userNotFound
        }
        
        // 2. Cargamos la familia (el contenedor de seguridad)
        guard let family = await dataService.getFamily(for: currentUserId) else {
            throw DataError.familyNotFound
        }
        
        // 3. Ahora lanzamos en paralelo lo que depende de la familia/usuario
        // Usamos el ID de la familia para obtener a los otros miembros (Pilar, Edgar, etc.)
        async let children = dataService.getChildren(for: family.id)
        async let members = dataService.getFamilyMembers(familyId: family.id)
        async let bonds = dataService.getChildBonds(for: currentUserId)
        async let events = dataService.getEvents(for: currentUserId)
        async let expenses = dataService.getExpenses(for: currentUserId)
        
        // 4. Await de todo el bloque
        let (loadedChildren, loadedMembers, loadedBonds, loadedEvents, loadedExpenses) = await (children, members, bonds, events, expenses)
        
        // 5. Generamos el contexto
        // 'allUsers' ahora son los miembros reales de la familia traídos de Supabase
        return DashboardContext.generate(
            for: loadedUser,
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
