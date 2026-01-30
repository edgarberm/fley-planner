//
//  WidgetComponent.swift
//  Dotlock
//
//  Created by Edgar Bermejo on 2/8/25.
//

import SwiftUI

struct WidgetComponent: View {
    @Environment(WidgetGridModel.self) var model
    
    let widget: Widget
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            switch widget.view {
                case .view(let view):
                    view
                    
                case .group(let group):
                    WidgetGroupComponent(group: group, widget: widget, width: width, height: height)
            }
            
            RoundedRectangle(cornerRadius: RADIUS, style: .continuous)
                .stroke(
                    Color.gray.opacity(widget.id == model.widgetTargetForGrouping ? 0.2 : 0),
                    lineWidth: widget.id == model.widgetTargetForGrouping ? 10 : 0
                )
                .animation(.easeInOut(duration: 0.4), value: widget.id == model.widgetTargetForGrouping)
        }
        .frame(width: width, height: height)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(RADIUS)
        .clipped()
    }
}


struct WidgetGroupComponent: View {
    @Environment(WidgetGridModel.self) var model
    
    let group: WidgetGroup
    let widget: Widget
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 0) {
                    ForEach(group.widgets) { w in
                        WidgetComponent(widget: w, width: width, height: height)
                            .id(w.id)
                            .containerRelativeFrame(.horizontal)
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : 0.8)
                                    .blur(radius: phase.isIdentity ? 0 : 1.0)
                            }
                    }
                }
                .onAppear {
                    if let targetChildID = model.groupScrollPositions[widget.id] ?? group.widgets.first?.id {
                        DispatchQueue.main.async {
                            proxy.scrollTo(targetChildID, anchor: .center)
                        }
                    }
                }
            }
        }
        .scrollDisabled(model.isDraggingWidget)
        .scrollTargetLayout()
        .scrollTargetBehavior(.paging)
        .scrollPosition(
            id: Binding(
                get: { model.groupScrollPositions[widget.id] ?? group.widgets.first?.id },
                set: { model.groupScrollPositions[widget.id] = $0 }
            )
        )
    }
}
