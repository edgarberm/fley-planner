//
//  UserDTO.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct UserBootstrapPayload: Encodable {
    let id: UUID
    let name: String
    let appleId: String
    let accountType: AccountType?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case appleId = "apple_id"
        case accountType = "account_type"
    }
}
