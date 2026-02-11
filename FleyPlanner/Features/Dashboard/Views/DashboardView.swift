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
    @State private var activeRoute: DashboardRouter?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading dashboard...")
            } else {
                WidgetGrid(
                    onWidgetTap: { widget in
                        activeRoute = .widgetDetail(widget)
                    },
                    onOpenSettings: {
                        activeRoute = .settings
                    }
                )
                .environment(model)
            }
        }
        .fullScreenSheet(
            ignoreSafeArea: true,
            isPresented: Binding(
                get: { activeRoute != .none },
                set: { isPresented in
                    if !isPresented {
                        activeRoute = .none
                    }
                }
            )
        ) { safeArea in
            routeView(for: activeRoute!)
                .safeAreaPadding(.top, safeArea.top)
        } background: {
            defaultBackground()
        }
        .task {
            await loadWidgets()
        }
    }
    
    @ViewBuilder
    private func routeView(for route: DashboardRouter) -> some View {
        switch route {
            case .widgetDetail(let widget):
                WidgetDetailRouter(widget: widget)
            case .settings:
                Text("Settings - TODO")
            case .addWidget:
                Text("Add Widget - TODO")
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
