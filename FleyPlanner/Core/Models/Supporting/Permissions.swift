//
//  Permissions.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

struct Permissions: Codable {
    var canEditCalendar: Bool
    var canViewExpenses: Bool
    var canAddExpenses: Bool
    var canApproveExpenses: Bool
    var canViewDocuments: Bool
}

enum VisibilityScope: String, Codable {
    case publicToFamily, adminsOnly
}
