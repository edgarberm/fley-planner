//
//  Models.swift
//  Dotlock
//
//  Created by Edgar Bermejo on 2/8/25.
//

import SwiftUI
import Observation

// MARK: - Constantes
let PADDING: CGFloat = 6.0
let SPACING: CGFloat = 16.0
let RADIUS: CGFloat = 22.0
let groupingThreshold: CGFloat = 12

// MARK: - Enums y Structs
enum WidgetSize {
    case wide
    case medium
}

struct WidgetGroup: Identifiable, Hashable {
    var id: UUID = .init()
    var widgets: [Widget] = []
}

enum WidgetContent {
    case view(AnyView)
    //case group(WidgetGroup)
}

struct Widget: Identifiable, Hashable {
    var id: UUID = .init()
    var size: WidgetSize
    var kind: DashboardWidgetKind
    
    var view: WidgetContent
    
    // UI state - no persistente
//    var frame: CGRect = .zero
//    var position: CGPoint = .zero
    
    // Hashable manual porque AnyView no es hashable
    static func == (lhs: Widget, rhs: Widget) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Modelo simplificado para un solo grid
@Observable
final class WidgetGridModel {
    var widgets: [Widget] = []
    
    var scrollOffset: CGFloat = 0
    
    var selectedWidget: Widget?
    var dragOffset: CGSize = .zero
    var selectedWidgetScale: CGFloat = 1.0
    var selectedWidgetPosition: CGRect = .zero
    var isDraggingWidget: Bool = false
    
    var widgetTargetForGrouping: UUID? = nil
    var groupScrollPositions: [UUID: UUID] = [:]
    
    var addMenuVisible: Bool = false
    
    init() {
        setupInitialData()
    }
    
    
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
    
    
    // MARK: - Private Setup
    private func setupInitialData() {
        widgets = createWidgetsList()
    }
}

extension WidgetGridModel {
    func refreshWidgetViews(context: DashboardContext) {
        widgets = widgets.map { widget in
            var w = widget
            w.view = .view(WidgetViewFactory.view(for: w, context: context))
            return w
        }
    }
}


// MARK: - Helper function

func createWidgetsList() -> [Widget] {
    return [
        .init(size: .wide, kind: .todaySummary, view: .view(AnyView(EmptyView()))),
        .init(size: .medium,kind: .miniCalendar, view: .view(AnyView(EmptyView()))),
        .init(size: .medium,kind: .balance, view: .view(AnyView(EmptyView()))),
        // .init(size: .wide, view: .group(_group)),
        .init(size: .wide, kind: .upcomingEvents,view: .view(AnyView(EmptyView()))),
        .init(size: .wide, kind: .pendingExpenses,view: .view(AnyView(EmptyView()))),
        .init(size: .medium, kind: .childrenStatus,view: .view(AnyView(EmptyView()))),
    ]
}
