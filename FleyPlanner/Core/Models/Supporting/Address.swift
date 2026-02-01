//
//  Address.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct Address: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let familyId: UUID
    var label: String
    var street: String
    var city: String
    var postalCode: String
    var country: String
    var latitude: Double?
    var longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case familyId = "family_id"
        case label
        case street
        case city
        case postalCode = "postal_code"
        case country
        case latitude
        case longitude
    }
}
