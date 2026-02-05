//
//  FullScreenCoverView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 4/2/26.
//

import SwiftUI

// MARK: - Preference Key para scroll offset

struct FSCVScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0.0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Full Screen Cover adaptado para Router

struct RouterFullScreenCover<Content: View>: View {
    @Environment(AppRouter.self) private var router
    let isPresented: Bool
    @ViewBuilder let content: Content
    
    @State private var dragOffset: CGFloat = 0.0
    @State private var scrollOffset: CGFloat = 0.0
    @State private var isDraggingDown: Bool = false
    @State private var tappingOnHandler: Bool = false
    
    var body: some View {
        if isPresented {
            GeometryReader { geometry in
                let safeTop = geometry.safeAreaInsets.top
                
                ZStack(alignment: .top) {
                    // Fondo con blur para ver el dashboard debajo
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.thinMaterial) // or ultraThinMaterial
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    
                    VStack(spacing: 0) {
                        // Handle y área superior
                        VStack(spacing: 0) {
                            Capsule()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 40, height: 6)
                                .padding(.bottom, 12)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 76, alignment: .bottom)
                        .background {
                            UnevenRoundedRectangle(
                                cornerRadii: .init(topLeading: 30, topTrailing: 30),
                                style: .continuous
                            )
                            .fill(Color.white.opacity(0.01))
                            .onLongPressGesture(minimumDuration: .infinity) {
                            } onPressingChanged: { tapping in
                                tappingOnHandler = tapping
                            }
                        }
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack {
                                content
                            }
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .preference(
                                            key: FSCVScrollOffsetPreferenceKey.self,
                                            value: proxy.frame(in: .named("scroll")).minY - safeTop
                                        )
                                        .onPreferenceChange(FSCVScrollOffsetPreferenceKey.self) { value in
                                            scrollOffset = value
                                        }
                                }
                            )
                        }
                        .scrollDisabled(isDraggingDown)
                        .zIndex(0)
                        .coordinateSpace(name: "scroll")
                        .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .offset(y: dragOffset)
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            if (scrollOffset >= 0 || tappingOnHandler) && value.translation.height > 0 {
                                isDraggingDown = true
                                dragOffset = value.translation.height
                            } else {
                                dragOffset = 0
                            }
                        }
                        .onEnded { value in
                            if (scrollOffset >= 0 || tappingOnHandler) && isDraggingDown {
                                handleDragEnd(value: value, geometry: geometry)
                            }
                            
                            isDraggingDown = false
                        }
                )
            }
            .edgesIgnoringSafeArea(.all)
            .transition(.move(edge: .bottom))
            .onDisappear {
                dragOffset = 0
            }
        }
    }
    
    private func handleDragEnd(value: DragGesture.Value, geometry: GeometryProxy) {
        let shouldDismiss = value.translation.height > geometry.size.height * 0.2 ||
        value.predictedEndTranslation.height > geometry.size.height * 0.3
        
        if shouldDismiss {
            // Calcular duración basada en la velocidad
            let velocity = abs(value.velocity.height)
            let remainingDistance = geometry.size.height - dragOffset
            
            // Duración mínima 0.15s, máxima 0.4s
            let duration = min(max(remainingDistance / velocity, 0.15), 0.4)
            
            withAnimation(.easeOut(duration: duration)) {
                dragOffset = geometry.size.height
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                router.closeSettings()
                dragOffset = 0
            }
        } else {
            withAnimation(.spring(response: 0.3)) {
                dragOffset = 0
            }
        }
    }
}
