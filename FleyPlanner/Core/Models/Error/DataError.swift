//
//  Data.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

enum DataError: Error, LocalizedError {
    case userNotFound
    case familyNotFound
    case unauthorized
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
            case .userNotFound:
                return "No hemos podido encontrar tu perfil de usuario."
            case .familyNotFound:
                return "No pareces estar vinculado a ninguna familia aún."
            case .unauthorized:
                return "No tienes permiso para realizar esta acción."
            case .networkError(let error):
                return "Error de conexión: \(error.localizedDescription)"
        }
    }
}
