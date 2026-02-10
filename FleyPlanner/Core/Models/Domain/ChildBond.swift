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
    var status: ChildBondStatus
    var expenseContribution: Decimal {
        didSet {
            expenseContribution = max(0, min(1, expenseContribution))
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case childId = "child_id"
        case userId = "user_id"
        case role
        case relationship
        case permissions
        case status
        case expenseContribution = "expense_contribution"
    }
}

enum ChildBondStatus: String, Codable, Hashable {
    case pending    // Solicitud enviada, pendiente de validación
    case active     // Vínculo válido y operativo
    case rejected   // Rechazado explícitamente por un adulto responsable
    case revoked    // Fue válido, pero se retiró el acceso
}

struct CreateChildBondPayload: Encodable {
    let id: UUID
    let childId: UUID
    let userId: UUID
    let role: Role
    let relationship: RelationshipType
    let permissions: Permissions
    let status: ChildBondStatus
    let expenseContribution: Decimal
    
    enum CodingKeys: String, CodingKey {
        case id
        case childId = "child_id"
        case userId = "user_id"
        case role
        case relationship
        case permissions
        case status
        case expenseContribution = "expense_contribution"
    }
}
