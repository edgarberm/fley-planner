//
//  Expense.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct Expense: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let payerId: UUID
    let totalAmount: Decimal
    let description: String
    let date: Date
    let category: ExpenseCategory
    var splits: [ExpenseSplit]
    
    var status: ExpenseStatus {
        if splits.allSatisfy(\.isPaid) {
            return .settled
        } else if splits.contains(where: \.isPaid) {
            return .partiallySettled
        } else {
            return .pending
        }
    }
    
    enum ExpenseCategory: String, Codable, CaseIterable {
        case medical = "Médico"
        case education = "Colegio"
        case clothing = "Ropa"
        case extracurricular = "Extraescolar"
        case food = "Comida"
        case other = "Otro"
    }
    
    static func create(
        childId: UUID,
        payerId: UUID,
        amount: Decimal,
        description: String,
        category: ExpenseCategory = .other,
        bonds: [ChildBond]
    ) -> Expense {
        let responsibleBonds = bonds.filter {
            $0.childId == childId && $0.expenseContribution > 0
        }
        
        let splits = responsibleBonds.map { bond in
            ExpenseSplit(
                id: UUID(),
                userId: bond.userId,
                amount: amount * bond.expenseContribution,
                isPaid: bond.userId == payerId,
                paidDate: bond.userId == payerId ? Date() : nil
            )
        }
        
        return Expense(
            id: UUID(),
            childId: childId,
            payerId: payerId,
            totalAmount: amount,
            description: description,
            date: Date(),
            category: category,
            splits: splits
        )
    }
}

struct ExpenseSplit: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var amount: Decimal
    var isPaid: Bool
    var paidDate: Date?
}

enum ExpenseStatus: String, Codable {
    case pending, partiallySettled, settled
}
