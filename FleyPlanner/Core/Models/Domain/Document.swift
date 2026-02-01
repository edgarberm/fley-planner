//
//  Document.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct Document: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let uploaderId: UUID
    var title: String
    var category: DocumentCategory
    var fileURL: URL
    var thumbnailURL: URL?
    var uploadDate: Date
    var expirationDate: Date?
    
    enum DocumentCategory: String, Codable, CaseIterable {
        case identification = "Identificación"
        case medical = "Médico"
        case school = "Colegio"
        case insurance = "Seguro"
        case legal = "Legal"
        case other = "Otro"
    }
}
