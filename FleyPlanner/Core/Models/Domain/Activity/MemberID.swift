//
//  MemberID.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 17/2/26.
//

import Foundation

struct MemberID: Identifiable, Hashable, Codable {
    let id: UUID
    let type: MemberType
    
    enum MemberType: String, Hashable, Codable {
        case adult
        case child
    }
    
    static func adult(_ id: UUID) -> MemberID {
        MemberID(id: id, type: .adult)
    }
    
    static func child(_ id: UUID) -> MemberID {
        MemberID(id: id, type: .child)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type = "member_type"
    }
}
