//
//  FloatingWidgetOverlay.swift
//  Dotlock
//
//  Created by Edgar Bermejo on 7/8/25.
//

import SwiftUI

struct FloatingWidgetOverlay: View {
    let widget: Widget
    let position: CGRect
    let scale: CGFloat
    let offset: CGSize
    let scrollOffset: CGFloat

    var body: some View {
        WidgetComponent(
            widget: widget,
            width: position.width,
            height: position.height
        )
        .scaleEffect(scale)
        .position(
            x: position.midX + offset.width + PADDING,
            y: position.midY + offset.height - scrollOffset
        )
        .shadow(
            color: .black.opacity(0.1),
            radius: shadowSyncAnimation(for: scale, maxRadius: 18),
            x: 0,
            y: 0
        )
        .transition(.identity)
    }
}
