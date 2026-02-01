//
//  CalendarEvent.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct CalendarEvent: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let creatorId: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var location: String?
    var notes: String?
    var type: EventType
    var assignedCaregiverId: UUID?
    var visibility: VisibilityScope
    
    enum EventType: String, Codable, CaseIterable {
        case pickup = "Recogida"
        case dropoff = "Entrega"
        case medical = "Médico"
        case school = "Colegio"
        case extracurricular = "Extraescolar"
        case other = "Otro"
        
        var icon: String {
            switch self {
                case .pickup: return "figure.walk.arrival"
                case .dropoff: return "figure.walk.departure"
                case .medical: return "cross.case"
                case .school: return "book"
                case .extracurricular: return "sportscourt"
                case .other: return "calendar"
            }
        }
    }
}
