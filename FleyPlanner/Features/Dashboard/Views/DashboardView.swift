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
    @State private var loadTask: Task<Void, Never>?
    
    // Para navegación a pantallas de onboarding
    @State private var showAddChild = false
    @State private var showInvitePartner = false
    
    var body: some View {
        Group {
            if let viewModel {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error)
                } else {
                    // Siempre mostrar WidgetGrid
                    WidgetGrid()
                        .environment(model)
                }
            } else {
                Color.clear
                    .onAppear {
                        initializeDashboard()
                    }
            }
        }
        .sheet(isPresented: $showAddChild) {
            // TODO: Tu pantalla de "Añadir niño"
            Text("Add Child Screen")
        }
        .sheet(isPresented: $showInvitePartner) {
            // TODO: Tu pantalla de "Invitar co-parent"
            Text("Invite Partner Screen")
        }
        .onDisappear {
            loadTask?.cancel()
            loadTask = nil
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Loading your dashboard...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            
            Text("Failed to load dashboard")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry") {
                initializeDashboard()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func initializeDashboard() {
        loadTask?.cancel()
        
        loadTask = Task { @MainActor in
            guard let user = appState.currentUser,
                  let family = appState.currentFamily else {
                print("❌ Missing user or family")
                return
            }
            
            print("🚀 Initializing dashboard for user: \(user.name), family: \(family.name)")
            
            let vm = DashboardViewModel(
                dataService: appState.dataService,
                currentUser: user,
                family: family
            )
            
            // Asignar viewModel
            viewModel = vm
            
            // Cargar datos
            do {
                try await vm.load()
                
                // ✨ Configurar widgets usando el nuevo sistema
                if let context = vm.context {
                    print("✅ Context loaded, setting up widgets...")
                    model.setupWidgets(context: context, user: user, family: family)
                    print("✅ Widgets setup complete. Total: \(model.widgets.count)")
                } else {
                    print("⚠️ No context available after load")
                }
            } catch {
                print("❌ Dashboard load failed: \(error)")
                // El error ya está en vm.error, así que la UI lo mostrará
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var appState = AppState(dataService: SupabaseService.shared)
    
    DashboardView()
        .environment(appState)
}
