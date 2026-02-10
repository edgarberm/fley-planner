//
//  WidgetModels.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 10/2/26.
//

import SwiftUI

// MARK: - Constants

let PADDING: CGFloat = 8.0
let SPACING: CGFloat = 12.0
let RADIUS: CGFloat = 22.0
let groupingThreshold: CGFloat = 12

// MARK: - Widget Structure

enum WidgetSize: String, Codable {
    case small   // 1x1
    case wide    // 2x1
}

enum WidgetKind: String, Codable {
    case today
    case calendar
    case children
}

struct Widget: Identifiable, Hashable {
    var id: UUID
    var size: WidgetSize
    var kind: WidgetKind
    
    init(id: UUID = UUID(), size: WidgetSize, kind: WidgetKind) {
        self.id = id
        self.size = size
        self.kind = kind
    }
    
    static func == (lhs: Widget, rhs: Widget) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
