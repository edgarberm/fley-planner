//
//  ChildBondDTO.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 10/2/26.
//

import Foundation

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
