//
//  DashboardContext.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import Foundation

struct DashboardContext {
    let currentUser: User
    let activeChildren: [ChildSummary]
    let pendingExpenses: [Expense]
    let upcomingEvents: [CalendarEvent]
    let totalBalance: UserBalance
    
    struct ChildSummary {
        let child: Child
        let currentCaregiver: User?
        let isWithCurrentUser: Bool
        let nextEvent: CalendarEvent?
        let nextCustodyChange: CustodyChange?
        let balance: UserBalance
        let unreviewedExpenses: Int
    }
    
    struct CustodyChange {
        let date: Date
        let fromUser: User
        let toUser: User
    }
    
    /// Factory method para generar el contexto del dashboard
    static func generate(
        for user: User,
        children: [Child],
        bonds: [ChildBond],
        events: [CalendarEvent],
        expenses: [Expense],
        allUsers: [User]
    ) -> DashboardContext {
        
        let now = Date()
        
        // Generar summaries de cada niño
        let summaries = children.compactMap { child -> ChildSummary? in
            // Filtrar bonds de este niño que incluyan al usuario actual
            guard bonds.contains(where: { $0.childId == child.id && $0.userId == user.id }) else {
                return nil // El usuario no tiene relación con este niño
            }
            
            // Determinar quién tiene al niño ahora
            let responsibleUserId = child.whoIsResponsible(
                at: now,
                events: events
            )
            
            let currentCaregiver = allUsers.first { $0.id == responsibleUserId }
            let isWithUser = responsibleUserId == user.id
            
            // Próximo evento del niño
            let nextEvent = events
                .filter { $0.childId == child.id && $0.startDate > now }
                .sorted { $0.startDate < $1.startDate }
                .first
            
            // Próximo cambio de custodia
            let nextChange = calculateNextCustodyChange(
                child: child,
                from: now,
                bonds: bonds,
                users: allUsers
            )
            
            // Balance del usuario con este niño
            let balance = calculateBalance(
                userId: user.id,
                childId: child.id,
                expenses: expenses
            )
            
            // Gastos sin revisar (pendientes de pagar por este usuario)
            let unreviewed = expenses.filter {
                $0.childId == child.id &&
                $0.splits.contains { $0.userId == user.id && !$0.isPaid }
            }.count
            
            return ChildSummary(
                child: child,
                currentCaregiver: currentCaregiver,
                isWithCurrentUser: isWithUser,
                nextEvent: nextEvent,
                nextCustodyChange: nextChange,
                balance: balance,
                unreviewedExpenses: unreviewed
            )
        }
        
        // Calcular balance total del usuario
        let totalBalance = summaries.reduce(
            UserBalance(owed: 0, owedTo: 0)
        ) { result, summary in
            UserBalance(
                owed: result.owed + summary.balance.owed,
                owedTo: result.owedTo + summary.balance.owedTo
            )
        }
        
        // Filtrar gastos pendientes del usuario
        let pendingExpenses = expenses.filter { expense in
            expense.splits.contains {
                $0.userId == user.id && !$0.isPaid
            }
        }
        
        // Próximos eventos (próximas 24-48h)
        let upcoming = events
            .filter { $0.startDate > now && $0.startDate < now.addingTimeInterval(86400 * 2) }
            .sorted { $0.startDate < $1.startDate }
        
        return DashboardContext(
            currentUser: user,
            activeChildren: summaries,
            pendingExpenses: pendingExpenses,
            upcomingEvents: upcoming,
            totalBalance: totalBalance
        )
    }
    
    // MARK: - Private Helpers
    
    private static func calculateNextCustodyChange(
        child: Child,
        from date: Date,
        bonds: [ChildBond],
        users: [User]
    ) -> CustodyChange? {
        // TODO: Implementación completa basada en CustodySchedule
        // Para MVP, retornamos nil
        // En producción, calcularías el próximo cambio de custodia
        // basado en el schedule del child
        return nil
    }
    
    private static func calculateBalance(
        userId: UUID,
        childId: UUID,
        expenses: [Expense]
    ) -> UserBalance {
        
        var owed: Decimal = 0
        var owedTo: Decimal = 0
        
        let childExpenses = expenses.filter { $0.childId == childId }
        
        for expense in childExpenses {
            if expense.payerId == userId {
                // Este usuario pagó, calcular cuánto le deben
                let unpaidSplits = expense.splits.filter {
                    $0.userId != userId && !$0.isPaid
                }
                owedTo += unpaidSplits.reduce(Decimal(0)) { $0 + $1.amount }
                
            } else {
                // Otro pagó, calcular cuánto debe este usuario
                if let userSplit = expense.splits.first(where: { $0.userId == userId }),
                   !userSplit.isPaid {
                    owed += userSplit.amount
                }
            }
        }
        
        return UserBalance(owed: owed, owedTo: owedTo)
    }
}
