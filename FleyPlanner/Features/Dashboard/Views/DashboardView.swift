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
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading dashboard...")
            } else {
                WidgetGrid()
                    .environment(model)
            }
        }
        .task {
            await loadWidgets()
        }
    }
    
    private func loadWidgets() async {
        guard let user = appState.currentUser else {
            print("❌ No user found")
            return
        }
        
        do {
            print("🔄 Loading widgets for user: \(user.name)")
            
            let configs = try await appState.dataService.getWidgetConfigs(for: user.id)
            
            await MainActor.run {
                // ✅ Configurar modelo para persistencia
                model.configure(userId: user.id, dataService: appState.dataService)
                
                model.setupWidgets(from: configs)
                isLoading = false
            }
            
            print("✅ Dashboard loaded with \(configs.count) widgets")
            
        } catch {
            print("❌ Failed to load widgets: \(error)")
            
            await MainActor.run {
                model.setupDefaultWidgets()
                isLoading = false
            }
        }
    }
}

//#Preview {
//    @Previewable @State var appState = AppState(dataService: SupabaseService.shared)
//
//    DashboardView()
//        .environment(appState)
//}
