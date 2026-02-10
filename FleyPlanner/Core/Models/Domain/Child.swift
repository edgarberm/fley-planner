//
//  Child.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct Child: Identifiable, Codable {
    let id: UUID
    let familyId: UUID  // ✅ AÑADIDO: Necesario para filtrar por familia
    var name: String
    var birthDate: Date?
    var avatarURL: URL?
    var custodyConfig: CustodyConfiguration?
    var medicalInfo: MedicalInfo?
    // TODO: addresses. From child bond
    
    enum CodingKeys: String, CodingKey {
        case id
        case familyId = "family_id"
        case name
        case birthDate = "birth_date"
        case avatarURL = "avater_url"
        case custodyConfig = "custody_config"
        case medicalInfo = "medical_info"
    }
    
    func whoIsResponsible(at date: Date, events: [CalendarEvent]) -> UUID? {
        let activeEvent = events
            .filter { event in
                event.childId == self.id &&
                event.assignedCaregiverId != nil &&
                date >= event.startDate &&
                date <= event.endDate
            }
            .sorted { $0.startDate > $1.startDate }
            .first
        
        if let manualCaregiver = activeEvent?.assignedCaregiverId {
            return manualCaregiver
        }
        
        return custodyConfig?.getResponsibleAt(date: date)
    }
}

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
