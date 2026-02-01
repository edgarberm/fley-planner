//
//  MedicalInfo.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct MedicalInfo: Codable {
    var bloodType: String?
    var allergies: [String]
    var medications: [String]
    var emergencyContacts: [EmergencyContact]
}
