//
//  Priority.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

enum Priority: String, Codable {
    case low = "Baja"
    case normal = "Normal"
    case high = "Alta"
    case urgent = "Urgente"
    
    var color: String {
        switch self {
            case .low: return "gray"
            case .normal: return "blue"
            case .high: return "orange"
            case .urgent: return "red"
        }
    }
}
