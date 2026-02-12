//
//  BlurredSheet.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 11/2/26.
//

import SwiftUI

extension View {
    func blurredSheet<Content: View>(
        _ style: AnyShapeStyle,
        isPresented: Binding<Bool>,
        onDismiss: @escaping () -> (),
        content: @escaping () -> Content
    ) -> some View {
        self.sheet(isPresented: isPresented, onDismiss: onDismiss) {
            content()
                .background(RemoveBackgroundColor())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Rectangle()
                        .fill(style)
                        .ignoresSafeArea(.container, edges: .all)
                    
                }
        }
    }
}

fileprivate struct RemoveBackgroundColor: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            uiView.superview?.superview?.backgroundColor = .clear
        }
    }
}
