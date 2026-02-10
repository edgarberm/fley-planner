//
//  AppError.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

enum AppError: LocalizedError {
    case notAuthenticated
    case invalidInviteCode
    case userNotFound
    case noFamily
    case unknown
    
    var errorDescription: String? {
        switch self {
            case .notAuthenticated:  return "Not authenticated"
            case .invalidInviteCode: return "Invalid invite code"
            case .userNotFound:      return "User not found after registration"
            case .noFamily:          return "User not found after registration"
            case .unknown:           return "An unknown error occurred"
        }
    }
}
