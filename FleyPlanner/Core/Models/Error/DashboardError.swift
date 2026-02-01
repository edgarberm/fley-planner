//
//  DashboardError.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

enum DashboardError: LocalizedError {
    case invalidUser
    case missingUserOrFamily
    
    var errorDescription: String? {
        switch self {
            case .invalidUser:
                return "Invalid user data"
            case .missingUserOrFamily:
                return "User or family information is missing"
        }
    }
}
