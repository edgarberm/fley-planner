//
//  ContentView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 30/1/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: DashboardViewModel?
    @State private var model = WidgetGridModel()
    
    var body: some View {
        NavigationStack {
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
    }
    
    private func loadDashboard(for user: User) async {
        let vm = DashboardViewModel(
            dataService: appState.dataService,
            currentUserId: user.id
        )
        viewModel = vm
        await vm.load()
        
        // Después de cargar los datos, sincronizamos widgets
        await vm.bindWidgets(model)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var appState = AppState(dataService: MockDataService.shared)
    
    ContentView()
        .environment(appState)
        .task {
            await appState.signIn(userId: MockData.shared.edgar.id)
        }
}
