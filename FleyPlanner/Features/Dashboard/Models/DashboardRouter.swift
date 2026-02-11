//
//  DashboardRoute.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 10/2/26.
//

import Foundation

enum DashboardRouter: Identifiable, Hashable {
    case widgetDetail(Widget)
    case settings
    case addWidget
    // Futuras rutas...
    
    var id: String {
        switch self {
            case .widgetDetail(let widget):
                return "widget-\(widget.id.uuidString)"
            case .settings:
                return "settings"
            case .addWidget:
                return "add-widget"
        }
    }
    
    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DashboardRouter, rhs: DashboardRouter) -> Bool {
        lhs.id == rhs.id
    }
}
