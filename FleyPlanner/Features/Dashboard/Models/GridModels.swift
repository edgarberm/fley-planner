//
//  Models.swift
//  Dotlock
//
//  Created by Edgar Bermejo on 2/8/25.
//

import SwiftUI
import Observation

@Observable
final class WidgetGridModel {
    var widgets: [Widget] = []
    
    // Drag state
    var scrollOffset: CGFloat = 0
    var selectedWidget: Widget?
    var dragOffset: CGSize = .zero
    var selectedWidgetScale: CGFloat = 1.0
    var selectedWidgetPosition: CGRect = .zero
    var isDraggingWidget: Bool = false
    
    var widgetTargetForGrouping: UUID? = nil
    
    init() {}
    
    // MARK: - Setup
    
    func setupDefaultWidgets() {
        widgets = [
            Widget(size: .wide, kind: .today),
            Widget(size: .small, kind: .calendar),
            Widget(size: .small, kind: .children)
        ]
    }
    
    // MARK: - Widget Management
    
    func updateWidgets(_ newWidgets: [Widget]) {
        widgets = newWidgets
    }
    
    func addWidget(_ widget: Widget) {
        widgets.append(widget)
    }
    
    func removeWidget(withId id: UUID) {
        widgets.removeAll { $0.id == id }
    }
    
    func moveWidget(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex >= 0 && sourceIndex < widgets.count,
              destinationIndex >= 0 && destinationIndex <= widgets.count else {
            return
        }
        
        let widget = widgets.remove(at: sourceIndex)
        let insertIndex = destinationIndex > sourceIndex ? destinationIndex - 1 : destinationIndex
        widgets.insert(widget, at: insertIndex)
    }
    
    func updateDragOffset(_ offset: CGSize) {
        dragOffset = offset
    }
}
