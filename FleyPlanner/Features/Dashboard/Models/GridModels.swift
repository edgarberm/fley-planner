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
    
    /// Configura widgets basándose en el estado de onboarding
    func setupWidgets(context: DashboardContext, user: User, family: Family) {
        let helper = DashboardOnboardingHelper(
            context: context,
            user: user,
            family: family
        )
        
        if helper.shouldShowOnboardingWidgets {
            // Mix de widgets de onboarding + normales
            setupMixedWidgets(helper: helper, context: context)
        } else {
            // Solo widgets normales
            setupNormalWidgets(context: context)
        }
    }
    
    /// Modo mixto: onboarding + normales
    private func setupMixedWidgets(helper: DashboardOnboardingHelper, context: DashboardContext) {
        var allWidgets: [Widget] = []
        
        // 1. Widgets de onboarding (prioridad alta)
        let onboardingKinds = helper.widgetsToShow()
        
        // ✨ LOG TEMPORAL
        print("🎯 Onboarding widgets to show: \(onboardingKinds.map { $0.rawValue })")
        
        for kind in onboardingKinds.prefix(3) {
            allWidgets.append(
                Widget(
                    size: kind.defaultSize,
                    kind: kind,
                    view: .view(WidgetViewFactory.onboardingView(for: kind))
                )
            )
        }
        
        // 2. Widgets normales (si hay datos)
        if !context.activeChildren.isEmpty {
            allWidgets.append(contentsOf: createNormalWidgets(context: context))
        }
        
        widgets = allWidgets
    }
    
    /// Solo widgets normales (usuario completo)
    private func setupNormalWidgets(context: DashboardContext) {
        widgets = createNormalWidgets(context: context)
    }
    
    /// Crea widgets normales con datos reales
    private func createNormalWidgets(context: DashboardContext) -> [Widget] {
        [
            Widget(
                size: .wide,
                kind: .todaySummary,
                view: .view(WidgetViewFactory.view(
                    for: Widget(size: .wide, kind: .todaySummary, view: .view(AnyView(EmptyView()))),
                    context: context
                ))
            ),
            Widget(
                size: .medium,
                kind: .miniCalendar,
                view: .view(WidgetViewFactory.view(
                    for: Widget(size: .medium, kind: .miniCalendar, view: .view(AnyView(EmptyView()))),
                    context: context
                ))
            ),
            Widget(
                size: .medium,
                kind: .balance,
                view: .view(WidgetViewFactory.view(
                    for: Widget(size: .medium, kind: .balance, view: .view(AnyView(EmptyView()))),
                    context: context
                ))
            ),
            Widget(
                size: .wide,
                kind: .upcomingEvents,
                view: .view(WidgetViewFactory.view(
                    for: Widget(size: .wide, kind: .upcomingEvents, view: .view(AnyView(EmptyView()))),
                    context: context
                ))
            ),
            Widget(
                size: .wide,
                kind: .pendingExpenses,
                view: .view(WidgetViewFactory.view(
                    for: Widget(size: .wide, kind: .pendingExpenses, view: .view(AnyView(EmptyView()))),
                    context: context
                ))
            ),
            Widget(
                size: .medium,
                kind: .childrenStatus,
                view: .view(WidgetViewFactory.view(
                    for: Widget(size: .medium, kind: .childrenStatus, view: .view(AnyView(EmptyView()))),
                    context: context
                ))
            )
        ]
    }
    
    // DEPRECATED: Eliminar cuando estemos seguros de que no se usa
    @available(*, deprecated, message: "Use setupWidgets(context:user:family:) instead")
    func setupOnboardingWidgets() {
        print("⚠️ setupOnboardingWidgets() is deprecated")
        widgets = []
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
