//
//  Widgets.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import SwiftUI

struct WidgetChildrenToday: Codable {
    let children: [WidgetChild]
    let lastUpdate: Date
    
    struct WidgetChild: Codable {
        let name: String
        let photoURL: String?
        let isWithMe: Bool
        let until: Date?
        let nextEvent: String?
    }
}

struct WidgetBalance: Codable {
    let totalOwed: Double
    let totalOwedTo: Double
    let pendingCount: Int
    let lastUpdate: Date
    
    static func from(balance: UserBalance, pendingCount: Int) -> WidgetBalance {
        WidgetBalance(
            totalOwed: NSDecimalNumber(decimal: balance.owed).doubleValue,
            totalOwedTo: NSDecimalNumber(decimal: balance.owedTo).doubleValue,
            pendingCount: pendingCount,
            lastUpdate: Date()
        )
    }
}

struct WidgetUpcomingEvents: Codable {
    let events: [WidgetEvent]
    let lastUpdate: Date
    
    struct WidgetEvent: Codable {
        let childName: String
        let title: String
        let date: Date
        let assignedTo: String?
    }
}
