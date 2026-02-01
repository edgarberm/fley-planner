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
    let familyId: UUID
    let userId: UUID
    
    enum CodingKeys: String, CodingKey {
        case familyId = "family_id"
        case userId = "user_id"
    }
}
