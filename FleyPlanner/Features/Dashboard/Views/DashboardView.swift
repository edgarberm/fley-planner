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
                    // Siempre mostrar WidgetGrid, sin importar si es onboarding o no
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
            
            // Configurar callbacks del grid model ANTES de asignar viewModel
            model.onAddChildTapped = {
                showAddChild = true
            }
            
            model.onInvitePartnerTapped = {
                showInvitePartner = true
            }
            
            // Asignar viewModel
            viewModel = vm
            
            // Cargar datos
            do {
                try await vm.load()
                
                // Vincular widgets (esto decidirá si mostrar onboarding o widgets normales)
                await vm.bindWidgets(model)
                
                print("✅ Dashboard initialized successfully")
                
            } catch {
                print("❌ Dashboard initialization failed: \(error)")
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

struct OnboardingWidgetView: View {
    let metadata: OnboardingWidgetMetadata
    let action: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(metadata.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(metadata.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
            }
            
            // Button
            Button(action: {
                action?()
            }) {
                HStack {
                    Text(metadata.actionTitle)
                        .font(.subheadline.weight(.semibold))
                    
                    Image(systemName: "arrow.right")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        colors: metadata.gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }
}

// MARK: - Welcome Widget (Wide)

struct OnboardingWelcomeWidgetView: View {
    let metadata: OnboardingWidgetMetadata
    
    var body: some View {
        VStack(spacing: 6) {
            Text(metadata.title)
                .font(.title2.bold())
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            
            Text(metadata.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        
    }
}


// MARK: - Preview

//#Preview {
//    // 1. Creamos un AppState de prueba
//    let mockAppState = AppState()
//    
//    // 2. Inyectamos datos de prueba para que no sea nil
//    mockAppState.currentUser = User(
//        id: UUID(),
//        name: "Usuario de Prueba",
//        appleId: "123",
//        accountType: .adult,
//        isPremium: false,
//        notificationSettings: NotificationSettings()
//    )
//    
//    mockAppState.currentFamily = Family(
//        id: UUID(),
//        name: "Familia Test",
//        createdBy: UUID(),
//        createdAt: Date(),
//        accessMembers: [],
//        childrenIds: []
//    )
//
//    DashboardView()
//        .environment(mockAppState) // 3. Pasamos el estado mockeado
//}
