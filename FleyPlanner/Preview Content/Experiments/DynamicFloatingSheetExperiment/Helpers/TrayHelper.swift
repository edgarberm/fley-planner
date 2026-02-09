//
//  TryHelper.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 9/2/26.
//

import SwiftUI

struct TrayConfig {
    var maxDetent: PresentationDetent
    var cornerRadius: CGFloat = 22
    var isInteractiveDismisDisabled: Bool = false
}

extension View {
    @ViewBuilder
    func systemTrayView<Content: View>(
        _ show: Binding<Bool>,
        config: TrayConfig = .init(maxDetent: .fraction(0.99)),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.sheet(isPresented: show) {
            content()
                .background(.background)
                .clipShape(.rect(cornerRadius: config.cornerRadius))
                .padding(.horizontal, 12)
                .frame(maxHeight: .infinity, alignment: .bottom)
                /// Config
                .presentationDetents([config.maxDetent])
                .presentationCornerRadius(0)
                .presentationBackground(.clear)
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(config.isInteractiveDismisDisabled)
                .background(RemoveSheetShadow())
        }
    }
}

fileprivate struct RemoveSheetShadow: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            if let shadowView = view.dropShadowView {
                shadowView.layer.shadowColor = UIColor.clear.cgColor
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}


extension UIView {
    var dropShadowView: UIView? {
        if let superview, String(describing: type(of: superview)) == "UIDropShadowView" {
            return superview
        }
        
        return superview?.dropShadowView
    }
}
