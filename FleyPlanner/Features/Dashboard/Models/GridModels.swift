//
//  Models.swift
//  Dotlock
//
//  Created by Edgar Bermejo on 2/8/25.
//

import SwiftUI
import Observation

// MARK: - Constants

let PADDING: CGFloat = 8.0
let SPACING: CGFloat = 12.0
let RADIUS: CGFloat = 22.0
let groupingThreshold: CGFloat = 12

// MARK: - Widget Structure

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
    
    // Metadata adicional para widgets de onboarding
    var onboardingAction: (() -> Void)?
    
    // Hashable manual porque AnyView no es hashable
    static func == (lhs: Widget, rhs: Widget) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Grid Model

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
    
    // Callbacks para widgets de onboarding
    var onAddChildTapped: (() -> Void)?
    var onInvitePartnerTapped: (() -> Void)?
    
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
    
    private func setupInitialData() {
        widgets = createWidgetsList()
    }
}

extension WidgetGridModel {
    /// Refresca los widgets con datos reales del contexto
    func refreshWidgetViews(context: DashboardContext) {
        widgets = widgets.map { widget in
            var w = widget
            w.view = .view(WidgetViewFactory.view(for: w, context: context))
            return w
        }
    }
    
    /// Crea widgets de onboarding cuando no hay datos
    func setupOnboardingWidgets() {
        print("🎯 Setting up onboarding widgets")
        
        widgets = [
            Widget(
                size: .wide,
                kind: .onboardingWelcome,
                view: .view(AnyView(EmptyView()))
            ),
            Widget(
                size: .medium,
                kind: .onboardingAddChild,
                view: .view(AnyView(EmptyView())),
                onboardingAction: { [weak self] in
                    self?.onAddChildTapped?()
                }
            ),
            Widget(
                size: .medium,
                kind: .onboardingInvitePartner,
                view: .view(AnyView(EmptyView())),
                onboardingAction: { [weak self] in
                    self?.onInvitePartnerTapped?()
                }
            )
        ]
        
        // Renderizar las vistas
        widgets = widgets.map { widget in
            var w = widget
            w.view = .view(WidgetViewFactory.onboardingView(for: w))
            return w
        }
    }
}

// MARK: - Helper Functions

func createWidgetsList() -> [Widget] {
    return [
        .init(size: .wide, kind: .todaySummary, view: .view(AnyView(EmptyView()))),
        .init(size: .medium, kind: .miniCalendar, view: .view(AnyView(EmptyView()))),
        .init(size: .medium, kind: .balance, view: .view(AnyView(EmptyView()))),
        .init(size: .wide, kind: .upcomingEvents, view: .view(AnyView(EmptyView()))),
        .init(size: .wide, kind: .pendingExpenses, view: .view(AnyView(EmptyView()))),
        .init(size: .medium, kind: .childrenStatus, view: .view(AnyView(EmptyView()))),
    ]
}
