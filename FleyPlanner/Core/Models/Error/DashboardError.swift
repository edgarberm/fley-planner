//
//  DashboardError.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

enum DashboardError: LocalizedError {
    case invalidUser
    case invalidFamily
    case loadFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidUser: return "Invalid user"
        case .invalidFamily: return "Invalid family"
        case .loadFailed(let error): return "Failed to load: \(error.localizedDescription)"
        }
    }
}
