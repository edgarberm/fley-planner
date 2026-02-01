//
//  EmergencyContact.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    var name: String
    var relationship: String
    var phone: String
    var isPrimary: Bool
}
