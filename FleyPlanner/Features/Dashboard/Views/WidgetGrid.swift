//
//  WidgetGrid.swift
//  Dotlock
//
//  Created by Edgar Bermejo on 2/8/25.
//

import SwiftUI

struct WidgetGrid: View {
    @Environment(WidgetGridModel.self) var model
    
    @State private var widgets: [Widget] = []
    @State private var hapticsTrigger: Bool = false
    
    @State private var shadowRadius: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let positions = calculateAbsolutePositions(in: geometry, widgets: widgets)
            let totalHeight = (positions.values.map { $0.maxY }.max() ?? 0) + 74
            
            ScrollView(showsIndicators: false) {
                GridTools()
                
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: totalHeight)
                    
                    ForEach(widgets) { widget in
                        if let position = positions[widget.id] {
                            WidgetComponent(
                                widget: widget,
                                width: position.width,
                                height: position.height
                            )
                            .position(
                                x: position.midX,
                                y: position.midY
                            )
                            .opacity(model.selectedWidget?.id == widget.id ? 0 : 1.0)
                            .simultaneousGesture(makeDragGesture(for: widget, in: geometry, positions: positions))
                        }
                    }
                }
                .padding(.horizontal, PADDING)
                .background(GeometryReader { proxy -> Color in
                    DispatchQueue.main.async {
                        model.scrollOffset = -proxy.frame(in: .named("scroll")).origin.y
                    }
                    return Color.clear
                })
            }
            .frame(maxWidth: geometry.size.width)
            .background(Color(UIColor.secondarySystemBackground))
            .coordinateSpace(name: "scroll")
            .scrollDisabled(model.isDraggingWidget)
            .overlay(alignment: .topLeading) {
                if let selectedWidget = model.selectedWidget {
                    FloatingWidgetOverlay(
                        widget: selectedWidget,
                        position: model.selectedWidgetPosition,
                        scale: model.selectedWidgetScale,
                        offset: model.dragOffset,
                        scrollOffset: model.scrollOffset
                    )
                }
            }
        }
        .sensoryFeedback(.impact, trigger: hapticsTrigger)
        .onAppear {
            syncFromModel()
        }
        .onChange(of: model.widgets) {
            syncFromModel()
        }
    }
    
    // MARK: - Drag Gesture
    private func makeDragGesture(for widget: Widget, in geometry: GeometryProxy, positions: [UUID: CGRect]) -> some Gesture {
        LongPressGesture(minimumDuration: 0.35)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .named("scroll")))
            .onChanged { value in
                switch value {
                    case .second(let status, let dragValue):
                        if status {
                            model.isDraggingWidget = true
                            
                            if model.selectedWidget == nil {
                                if let position = positions[widget.id] {
                                    model.selectedWidget = widget
                                    model.selectedWidgetPosition = position
                                    model.selectedWidgetScale = 1.04
                                }
                                hapticsTrigger.toggle()
                            }
                            
                            if let dragValue = dragValue, model.selectedWidget?.id == widget.id {
                                model.updateDragOffset(dragValue.translation)
                                
                                let result = reorderedWidgetsIfNeeded(
                                    dragLocation: dragValue.location,
                                    geometry: geometry,
                                    positions: positions,
                                    widgets: widgets,
                                    selectedWidget: model.selectedWidget!,
                                    scrollOffset: model.scrollOffset,
                                    widgetTargetForGrouping: model.widgetTargetForGrouping
                                )
                                
                                if let updatedWidgets = result.widgetList {
                                    withAnimation(.snappy(duration: 0.35, extraBounce: 0)) {
                                        widgets = updatedWidgets
                                    }
                                }
                                
                                // TODO: - Esto crea grupos de widgets
                                //model.widgetTargetForGrouping = result.groupingTarget
                            }
                        }
                    default:
                        break
                }
            }
            .onEnded { _ in
                var updated = widgets
                var selectedWidgetPosition = model.selectedWidgetPosition
                
                if let targetID = model.widgetTargetForGrouping,
                   let dragged = model.selectedWidget,
                   let targetIndex = updated.firstIndex(where: { $0.id == targetID }),
                   // draggedIndex
                   let _ = updated.firstIndex(where: { $0.id == dragged.id }) {
                    
                    // Sacar los dos widgets
                    let targetWidget = updated.remove(at: targetIndex)
                    
                    // TODO: - Grouping gidgets
                    // Ajustar índice si el arrastrado estaba antes del target
                    // let draggedIndexAdjusted = targetIndex > draggedIndex ? draggedIndex : draggedIndex - 1
                    
                    //let draggedWidget = updated.remove(at: draggedIndexAdjusted)
                    
                    // Crear grupo
                    //                    let group = WidgetGroup(widgets: [draggedWidget, targetWidget])
                    //                    let groupWidget = Widget(id: targetWidget.id, size: .medium, view: .group(group))
                    
                    // Insertar en posición del target original
                    //updated.insert(groupWidget, at: targetIndex)
                    
                    selectedWidgetPosition = positions[targetWidget.id] ?? .zero
                    
                    let packed = compactWidgets(updated)
                    
                    withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                        widgets = packed
                    }
                    
                    DispatchQueue.main.async {
                        syncToModel()
                    }
                } else {
                    selectedWidgetPosition = positions[widget.id] ?? .zero
                    
                    // Compactar normal si no hay agrupación
                    let packed = compactWidgets(widgets)
                    if packed.map(\.id) != widgets.map(\.id) {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            widgets = packed
                        }
                    }
                    
                    DispatchQueue.main.async {
                        syncToModel()
                    }
                }
                
                withAnimation(.snappy(duration: 0.25, extraBounce: 0), completionCriteria: .logicallyComplete) {
                    model.dragOffset = .zero
                    model.selectedWidgetScale = 1.0
                    model.selectedWidgetPosition = selectedWidgetPosition
                    model.widgetTargetForGrouping = nil
                } completion: {
                    model.selectedWidget = nil
                    model.selectedWidgetPosition = .zero
                    model.isDraggingWidget = false
                }
            }
    }
    
    // MARK: - Sincronización con modelo
    private func syncFromModel() {
        widgets = model.widgets
    }
    
    private func syncToModel() {
        model.updateWidgets(widgets)
    }
}



