//
//  DashboardWidgetConfig.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 10/2/26.
//

import Foundation

struct DashboardWidgetConfig: Identifiable, Codable, Equatable {
    let id: UUID
    let userId: UUID
    var kind: WidgetKind
    var size: WidgetSize
    var position: Int
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case kind = "widget_kind"
        case size = "widget_size"
        case position
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(id: UUID = UUID(), userId: UUID, kind: WidgetKind, size: WidgetSize, position: Int) {
        self.id = id
        self.userId = userId
        self.kind = kind
        self.size = size
        self.position = position
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
