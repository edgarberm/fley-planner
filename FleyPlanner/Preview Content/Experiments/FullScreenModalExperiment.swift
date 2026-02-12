//
//  FullScreenModalExperiment.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 11/2/26.
//

import SwiftUI

struct ExampleView: View {
    @State private var isShowingModal = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            Button("Abrir modal") {
                isShowingModal = true
            }
            .font(.title2)
            .buttonStyle(.borderedProminent)
        }
        .fullScreenCover(isPresented: $isShowingModal) {
            DragDismissModal(isPresented: $isShowingModal)
        }
    }
}

struct DragDismissModal: View {
    @Binding var isPresented: Bool

    @GestureState private var dragState = DragState.inactive
    @State private var offsetY: CGFloat = 0

    private let dismissThreshold: CGFloat = 180

    enum DragState {
        case inactive
        case dragging(translation: CGSize)

        var translation: CGSize {
            switch self {
            case .inactive: return .zero
            case .dragging(let trans): return trans
            }
        }
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack {
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 60, height: 6)
                    .padding(.top, 10)

                Text("Arrastra hacia abajo para cerrar")
                    .font(.title2)
                    .padding(.top, 24)

                Spacer()
            }
        }
        .offset(y: offsetY + dragState.translation.height)
        .gesture(dragGesture)
        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.85), value: offsetY + dragState.translation.height)
    }

    var dragGesture: some Gesture {
        DragGesture()
            .updating($dragState) { value, state, _ in
                state = .dragging(translation: value.translation)
            }
            .onEnded(handleDragEnded(_:))
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        let translation = value.translation.height
        let velocity = value.predictedEndLocation.y - value.location.y

        if translation > dismissThreshold || velocity > 500 {
            withAnimation(.spring()) {
                isPresented = false
            }
        } else {
            withAnimation(.spring()) {
                offsetY = 0
            }
        }
    }
}


#Preview {
    ExampleView()
}
