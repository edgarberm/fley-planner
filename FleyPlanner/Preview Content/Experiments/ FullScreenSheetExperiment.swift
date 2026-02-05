//
//   FullScreenSheet.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 5/2/26.
//

import SwiftUI

struct FullScreenSheetExperiment: View {
    @State private var showSheet: Bool = false
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            List {
                Button("Show sheet") {
                    showSheet.toggle()
                }
                .matchedTransitionSource(id: "BUTTON", in: animation)
            }
            .navigationTitle("Full-Screen Sheet")
        }
        .fullScreenSheet(ignoreSafeArea: true, isPresented: $showSheet) { safeArea in
            ScrollView(.vertical) {
                VStack {
                    Text("Settings")
                        .font(.largeTitle.bold())
                        .listRowBackground(Color.clear)
                    
                    ForEach(0..<100) { i in
                        Text("Elemento \(i)")
                            .listRowBackground(Color.clear)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .scrollContentBackground(.hidden)
            .safeAreaPadding(.top, safeArea.top)
            //.navigationTransition(.zoom(sourceID: "BUTTON", in: animation))
        } background: {
            RoundedRectangle(cornerRadius: 60)
                .fill(.blue.gradient)
        }
    }
}



#Preview {
    FullScreenSheetExperiment()
}
