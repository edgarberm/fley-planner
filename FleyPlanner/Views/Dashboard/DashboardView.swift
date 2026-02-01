//
//  DashboardView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: DashboardViewModel?
    @State private var model = WidgetGridModel()
    
    var body: some View {
        Group {
            if let viewModel, let _ = viewModel.context {
                
                // Mostramos el grid
                WidgetGrid()
                    .environment(model)
                    .task {
                        // Sincronizamos widgets con datos reales
                        await viewModel.bindWidgets(model)
                    }
                
            } else if viewModel?.isLoading == true {
                ProgressView("Loading...")
            } else if let user = appState.currentUser {
                ProgressView("Initializing...")
                    .task {
                        await loadDashboard(for: user)
                    }
            } else {
                Text("Not authenticated")
            }
        }
    }
    
    private func loadDashboard(for user: User) async {
        guard let user = appState.currentUser,
              let family = appState.currentFamily else { return }
        
        let vm = DashboardViewModel(
            dataService: appState.dataService,
            currentUser: user,
            familyId: family.id
        )
        viewModel = vm
        await vm.load()
        await vm.bindWidgets(model)
    }
}

//#Preview {
//    @Previewable @State var appState = AppState(dataService: SupabaseService.shared)
//    
//    DashboardView()
//        .environment(appState)
//}
