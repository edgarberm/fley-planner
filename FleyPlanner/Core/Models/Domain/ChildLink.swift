//
//  ChildLink.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

/// Vínculo de un TEEN/CHILD con niños de su familia
/// Los niños NO tienen ChildBonds, solo ChildLinks
struct ChildLink: Identifiable, Codable {
    let id: UUID
    let childId: UUID
    let userId: UUID // Debe ser accountType: .teen
    let linkType: LinkType
    
    enum LinkType: String, Codable {
        case selfChild   // El propio teen
        case sibling     // Hermano/a del teen
    }
}
