//
//  AccountType.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

enum AccountType: String, Codable {
    case adult
    case children
    
    var defaultPermissions: Permissions {
        switch self {
            case .adult:
                return Permissions(
                    canEditCalendar: true,
                    canViewExpenses: true,
                    canAddExpenses: true,
                    canApproveExpenses: false,
                    canViewDocuments: true
                )
            case .children:
                return Permissions(
                    canEditCalendar: false,
                    canViewExpenses: false,
                    canAddExpenses: false,
                    canApproveExpenses: false,
                    canViewDocuments: false
                )
        }
    }
}
