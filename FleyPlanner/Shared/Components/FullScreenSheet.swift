//
//  FullScreenSheet.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 5/2/26.
//

//        .fullScreenSheet(
//            ignoreSafeArea: true,
//            isPresented: Binding(
//                get: { activeRoute != .none },
//                set: { isPresented in
//                    if !isPresented {
//                        activeRoute = .none
//                    }
//                }
//            )
//        ) { safeArea in
//            routeView(for: activeRoute!)
//                .scrollContentBackground(.hidden)
//                .safeAreaPadding(.top, safeArea.top)
//        } background: {
//            fullScreenSheetBackground()
//        }

import SwiftUI

extension View {
    @ViewBuilder
    func fullScreenSheetBackground() -> some View {
        RoundedRectangle(cornerRadius: displayCornerRadius())
            .fill(.thinMaterial)
    }
    
    @ViewBuilder
    func fullScreenSheet<Content: View, Background: View>(
        ignoreSafeArea: Bool = false,
        isPresented: Binding<Bool>,
        showDragIndicator: Bool = true,
        @ViewBuilder content: @escaping (UIEdgeInsets) -> Content,
        @ViewBuilder background: @escaping () -> Background?
    ) -> some View {
        self.fullScreenCover(isPresented: isPresented) {
            FullScreenSheet(
                ignoreSafeArea: ignoreSafeArea,
                showDragIndicator: showDragIndicator,
                content: content,
                background: background
            )
        }
    }
}

fileprivate struct CustomPangesture: UIGestureRecognizerRepresentable {
    var handle: (UIPanGestureRecognizer) -> ()
    
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        gesture.delegate = context.coordinator
        return gesture
    }
    
    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {}
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        handle(recognizer)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
                return false
            }
            
            let velocity = panGesture.velocity(in: panGesture.view).y
            var offset: CGFloat = 0
            
            if let cView = otherGestureRecognizer.view as? UICollectionView {
                offset = cView.contentOffset.y + cView.adjustedContentInset.top
            }
            
            if let sView = otherGestureRecognizer.view as? UIScrollView {
                offset = sView.contentOffset.y + sView.adjustedContentInset.top
            }
            
            let isElligible = Int(offset) <= 1 && velocity > 0
            
            return isElligible
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            let status = (gestureRecognizer.view?.gestureRecognizers?.contains(where: {
                ($0.name ?? "").localizedStandardContains("zoom")
            })) ?? false
            
            return !status
        }
    }
}

struct FullScreenSheet<Content: View, Background: View>: View {
    var ignoreSafeArea: Bool
    var showDragIndicator: Bool
    
    @ViewBuilder var content: (UIEdgeInsets) -> Content
    @ViewBuilder var background: Background
    
    @Environment(\.dismiss) var dismiss
    
    @State private var offset: CGFloat = 0
    @State private var scrollDisabled: Bool = false
    
    var body: some View {
        content(safeArea)
            .scrollDisabled(scrollDisabled)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 10)
            .overlay(alignment: .top) {
                if showDragIndicator {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.001))
                            .frame(width: UIScreen.main.bounds.width, height: 80)
                        
                        Capsule()
                            .fill(Color.gray.opacity(0.8))
                            .frame(width: 40, height: 6)
                            .padding(.top, ignoreSafeArea ? safeArea.top - 18 : 8)
                    }
                }
            }
            .contentShape(.rect)
            .offset(y: offset)
            .gesture(
                CustomPangesture { gesture in
                    let state = gesture.state
                    let halfHeight = windowSize.height / 2
                    let translation = min(max(gesture.translation(in: gesture.view).y, 0), windowSize.height)
                    let velocity = min(max(gesture.velocity(in: gesture.view).y / 5, 0), halfHeight)
                    
                    switch state {
                        case .began:
                            scrollDisabled = true
                            offset = translation
                        case .changed:
                            guard scrollDisabled else { return }
                            offset = translation
                        case .ended, .cancelled, .failed:
                            gesture.isEnabled = false
                            
                            if (translation + velocity) > halfHeight {
                                /// Closing and removing
                                withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                                    offset = windowSize.height
                                }
                                
                                Task {
                                    try? await Task.sleep(for: .seconds(0.3))
                                    
                                    var transaction = Transaction()
                                    transaction.disablesAnimations = true
                                    withTransaction(transaction) {
                                        dismiss()
                                    }
                                }
                            } else {
                                /// Reset
                                withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                                    offset = 0
                                }
                                
                                Task {
                                    try? await Task.sleep(for: .seconds(0.3))
                                    scrollDisabled = false
                                    gesture.isEnabled = true
                                }
                            }
                        default: ()
                    }
                }
            )
            .presentationBackground {
                background
                    .offset(y: offset)
            }
            .ignoresSafeArea(.container, edges: ignoreSafeArea ? .all : [])
    }
    
    var windowSize: CGSize {
        if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow {
            return window.screen.bounds.size
        }
        
        return .zero
    }
    
    var safeArea: UIEdgeInsets {
        if let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow {
            return window.safeAreaInsets
        }
        
        return .zero
    }
}
