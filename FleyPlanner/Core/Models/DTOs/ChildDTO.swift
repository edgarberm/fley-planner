//
//  ChildDTO.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 10/2/26.
//

import Foundation

struct CreateChildPayload: Encodable {
    let id: UUID
    let familyId: UUID
    let name: String
    let birthDate: Date?
    let avatarURL: URL?
    let custodyConfig: CustodyConfiguration?
    let medicalInfo: MedicalInfo?
    
    enum CodingKeys: String, CodingKey {
        case id
        case familyId = "family_id"
        case name
        case birthDate = "birth_date"
        case avatarURL = "avatar_url"
        case custodyConfig = "custody_config"
        case medicalInfo = "medical_info"
    }
}
