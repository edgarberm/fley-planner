//
//  CareItem.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct CareItem: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let createdBy: UUID
    var title: String
    var notes: String?
    var type: CareItemType
    var priority: Priority
    var status: CareItemStatus
    var visibility: VisibilityScope
    var dueDate: Date?
    var assignedTo: UUID?
    var createdAt: Date
    var completedAt: Date?
}

enum CareItemType: String, Codable, CaseIterable {
    case clothing = "Ropa/Uniforme"
    case medication = "Medicación"
    case school = "Colegio"
    case food = "Comida"
    case logistics = "Logística"
    case health = "Salud"
    case other = "Otro"
    
    var icon: String {
        switch self {
            case .clothing: return "tshirt"
            case .medication: return "pills"
            case .school: return "book"
            case .food: return "fork.knife"
            case .logistics: return "backpack"
            case .health: return "heart"
            case .other: return "checklist"
        }
    }
}

enum CareItemStatus: String, Codable {
    case open = "Pendiente"
    case inProgress = "En progreso"
    case completed = "Completado"
    case blocked = "Bloqueado"
}
