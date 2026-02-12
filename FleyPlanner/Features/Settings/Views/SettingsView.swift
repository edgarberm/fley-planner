//
//  SettingsView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 11/2/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("My Profile", value: "PROFILE")
            }
            .navigationDestination(for: String.self) { value in
                DetailView(value: value)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DetailView: View {
    let value: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Tu contenido
            Text("You are into \(value)")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Botón flotante
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .padding(.leading, 16)
            .padding(.top, 8)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .background {
            SwipeBackEnabler()
        }
    }
}

struct SwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
            uiViewController.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
    }
}

#Preview {
    let mockState = AppState()
    mockState.currentUser = User(
        id: UUID(),
        name: "Edgar bermejo",
        email: "edgar@test.com",
        appleId: "preview_apple_id",
        accountType: nil,
        avatarURL: nil,
        isPremium: true,
        contactInfo: nil,
        notificationSettings: .default,
        profileCompleted: true
    )
    
    return SettingsView()
        .environment(mockState)
}
