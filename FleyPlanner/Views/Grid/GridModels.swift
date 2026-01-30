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
    case group(WidgetGroup)
}

struct Widget: Identifiable, Hashable {
    var id: UUID = .init()
    var size: WidgetSize
    
    var view: WidgetContent
    
    // UI state - no persistente
    var frame: CGRect = .zero
    var position: CGPoint = .zero
    
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
    // MARK: - Core Data
    var widgets: [Widget] = []
    // MARK: - UI State para scroll
    var scrollOffset: CGFloat = 0
    // MARK: - UI State para drag y drop
    var selectedWidget: Widget?
    var dragOffset: CGSize = .zero
    var selectedWidgetScale: CGFloat = 1.0
    var selectedWidgetPosition: CGRect = .zero
    var isDraggingWidget: Bool = false
    // MARK: - grouping
    var widgetTargetForGrouping: UUID? = nil
    var groupScrollPositions: [UUID: UUID] = [:] 
    // MARK: - UI
    var addMenuVisible: Bool = false
    
    init() {
        setupInitialData()
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
    
    // MARK: - Private Setup
    private func setupInitialData() {
        widgets = createWidgetsList()
    }
}


// MARK: - Helper function
func createWidgetsList() -> [Widget] {
//    let groupedWidgets: [Widget] = [
//        .init(size: .medium, view: .view(AnyView(ExampleWidgetView()))),
//        .init(size: .medium, view: .view(AnyView(ExampleWidgetView()))),
//        .init(size: .medium, view: .view(AnyView(ExampleWidgetView()))),
//        .init(size: .medium, view: .view(AnyView(ExampleWidgetView())))
//    ]
    
//    let _group = WidgetGroup(widgets: groupedWidgets)
    
    return [
//        .init(size: .wide, view: .view(AnyView(
//            CardWidgetView(
//                size: .wide,
//                type: .mastercard,
//                name: "My mastercard",
//                bank: "ING",
//                number: "1234123412341234",
//                expiration: .init(month: 03, year: 28),
//                color: Color.green
//            )
//        ))),
//        .init(size: .medium, view: .view(AnyView(
//            CardWidgetView(
//                size: .medium,
//                type: .visa,
//                name: "My visa",
//                bank: "Deutsche Bank",
//                number: "1234123412341234",
//                expiration: .init(month: 03, year: 28),
//                color: Color.pink
//            )
//        ))),
        .init(size: .wide, view: .view(AnyView(ExampleWidgetView()))),
        .init(size: .medium, view: .view(AnyView(ExampleWidgetView()))),
        .init(size: .medium, view: .view(AnyView(ExampleWidgetView()))),
//        .init(size: .wide, view: .group(_group)),
        .init(size: .wide, view: .view(AnyView(ExampleWidgetView()))),
        .init(size: .medium, view: .view(AnyView(ExampleWidgetView()))),
        .init(size: .medium, view: .view(AnyView(ExampleWidgetView()))),
        .init(size: .medium, view: .view(AnyView(ExampleWidgetView()))),
    ]
}
