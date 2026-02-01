//
//  ChildBond.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

/// Relación entre un ADULTO y un niño
/// Define: rol, permisos, contribución financiera
struct ChildBond: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let userId: UUID // Debe ser accountType: .adult
    var role: Role
    var relationship: RelationshipType
    var permissions: Permissions
    
    var expenseContribution: Decimal {
        didSet {
            expenseContribution = max(0, min(1, expenseContribution))
        }
    }
}
