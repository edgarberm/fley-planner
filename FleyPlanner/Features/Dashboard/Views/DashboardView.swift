//
//  DashboardView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var model = WidgetGridModel()
    
    var body: some View {
        WidgetGrid()
            .environment(model)
            .onAppear {
                model.setupDefaultWidgets()
            }
    }
}

//#Preview {
//    @Previewable @State var appState = AppState(dataService: SupabaseService.shared)
//    
//    DashboardView()
//        .environment(appState)
//}
