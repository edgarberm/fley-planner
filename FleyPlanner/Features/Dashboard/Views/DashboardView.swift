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
    
    // ✅ Estado de navegación centralizado
    @State private var activeFlow: OnboardingFlow?
    
    enum OnboardingFlow {
        case completeProfile
        case addChild
        case invitePartner
        case childDetails
    }
    
    var body: some View {
        Group {
            if let viewModel {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error)
                } else {
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
        // ✅ Modal único para todos los flujos
        .systemTrayView(Binding(
            get: { activeFlow != nil },
            set: { if !$0 { activeFlow = nil } }
        )) {
            if let flow = activeFlow {
                flowView(for: flow)
            }
        }
        // ✅ Refresh automático cuando cambia user o family
        .onChange(of: appState.currentUser) { _, _ in refreshDashboard() }
        .onChange(of: appState.currentFamily) { _, _ in refreshDashboard() }
        .onDisappear {
            loadTask?.cancel()
            loadTask = nil
        }
    }
    
    // MARK: - Subviews
    
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
    
    @ViewBuilder
    private func flowView(for flow: OnboardingFlow) -> some View {
        switch flow {
        case .completeProfile:
            Text("Profile Flow - TODO")
        case .addChild:
            AddChildFlowView()
        case .invitePartner:
            Text("Invite Flow - TODO")
        case .childDetails:
            Text("Child Details Flow - TODO")
        }
    }
    
    // MARK: - Dashboard Initialization
    
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
            
            viewModel = vm
            
            do {
                try await vm.load()
                
                if let context = vm.context {
                    print("✅ Context loaded, setting up widgets...")
                    
                    // ✅ Pasar callback para abrir flujos
                    model.setupWidgets(
                        context: context,
                        user: user,
                        family: family,
                        onOpenFlow: { flow in
                            activeFlow = flow
                        }
                    )
                    
                    print("✅ Widgets setup complete. Total: \(model.widgets.count)")
                } else {
                    print("⚠️ No context available after load")
                }
            } catch {
                print("❌ Dashboard load failed: \(error)")
            }
        }
    }
    
    // MARK: - Refresh
    
    private func refreshDashboard() {
        Task { @MainActor in
            guard let user = appState.currentUser,
                  let family = appState.currentFamily,
                  let vm = viewModel else { return }
            
            print("🔄 Refreshing dashboard...")
            
            do {
                try await vm.load()
                
                if let context = vm.context {
                    model.setupWidgets(
                        context: context,
                        user: user,
                        family: family,
                        onOpenFlow: { flow in
                            activeFlow = flow
                        }
                    )
                    print("✅ Dashboard refreshed")
                }
            } catch {
                print("❌ Refresh failed: \(error)")
            }
        }
    }
}
// MARK: - Preview

//#Preview {
//    @Previewable @State var appState = AppState(dataService: SupabaseService.shared)
//    
//    DashboardView()
//        .environment(appState)
//}
