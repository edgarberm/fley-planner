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
    let onTap: () -> Void
    
    init(
        widget: Widget,
        width: CGFloat,
        height: CGFloat,
        onTap: @escaping () -> Void = {}
    ) {
        self.widget = widget
        self.width = width
        self.height = height
        self.onTap = onTap
    }
    
    var body: some View {
        ZStack {
            // Contenido del widget según su kind
            widgetContent
            
            // Borde de agrupación (si aplica)
            RoundedRectangle(cornerRadius: RADIUS, style: .continuous)
                .stroke(
                    Color.gray.opacity(widget.id == model.widgetTargetForGrouping ? 0.2 : 0),
                    lineWidth: widget.id == model.widgetTargetForGrouping ? 10 : 0
                )
                .animation(.easeInOut(duration: 0.4), value: widget.id == model.widgetTargetForGrouping)
        }
        .frame(width: width, height: height)
        .background(Color.white)
        .cornerRadius(RADIUS)
        .clipped()
        .onTapGesture {
            onTap()
        }
    }
    
    @ViewBuilder
    private var widgetContent: some View {
        switch widget.kind {
        case .today:
            Text("Today")
                .font(.title2.bold())
                .foregroundStyle(.secondary)
        case .calendar:
            Text("Calendar")
                .font(.title2.bold())
                .foregroundStyle(.secondary)
        case .children:
            Text("Children")
                .font(.title2.bold())
                .foregroundStyle(.secondary)
        }
    }
}
