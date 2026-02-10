//
//  Family.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct JoinFamilyPayload {
    let familyId: UUID
    let userId: UUID
    
    enum CodingKeys: String, CodingKey {
        case familyId = "family_id"
        case userId = "user_id"
    }
}

struct FamilyMemberInsert: Encodable {
    let id: UUID?
    let familyId: UUID
    let userId: UUID
    
    enum CodingKeys: String, CodingKey {
        case id
        case familyId = "family_id"
        case userId = "user_id"
    }
    
    init(familyId: UUID, userId: UUID) {
        self.id = UUID()  // Generar ID automáticamente
        self.familyId = familyId
        self.userId = userId
    }
}
