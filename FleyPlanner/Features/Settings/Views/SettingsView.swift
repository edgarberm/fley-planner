//
//  SettingsView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 11/2/26.
//

import SwiftUI

enum SettingsRoute: Hashable {
    case myProfile
    case myFamily
    case account
    case appearance
    case notifications
}

enum SettingsExternalLink {
    case termsOfService
    case privacyPolicy
    
    var url: URL {
        switch self {
        case .termsOfService: URL(string: "https://fley.io/terms")!
        case .privacyPolicy:  URL(string: "https://fley.io/privacy")!
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    @Environment(\.controlSize) var controlSize
    
    // @State private var path = NavigationPath() // evitar el warning `NavigationStack(path: $path)`
    @State private var currentSubView: SettingsRoute? = nil
    
    @State private var magicEnabled = false
    
    var body: some View {
        NavigationStack {
            List {
                SettingsRow(icon: "square-user-round", title: "My Profile") {
                    NavigationLink(value: SettingsRoute.myProfile) { EmptyView() }
                        .opacity(0)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                
                SettingsRow(icon: "users", title: "My Family") {
                    NavigationLink(value: SettingsRoute.myFamily) { EmptyView() }
                        .opacity(0)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                
                SettingsRow(icon: "award", title: "Account") {
                    NavigationLink(value: SettingsRoute.account) { EmptyView() }
                        .opacity(0)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                
                SettingsRow(icon: "message-square-dot", title: "Notifications") {
                    NavigationLink(value: SettingsRoute.account) { EmptyView() }
                        .opacity(0)
                    HStack(spacing: 18) {
                        ProBadge()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                
//                SettingsRow(icon: "message-square-dot", title: "Notifications") {
//                    HStack(spacing: 8) {
//                        ProBadge()
//                        Toggle("", isOn: $magicEnabled)
//                            .labelsHidden()
//                            .scaleEffect(0.8)
//                    }
//                }
                
                SettingsRow(icon: "moon", title: "Appearance") {
                    NavigationLink(value: SettingsRoute.appearance) { EmptyView() }
                        .opacity(0)
                    
                    HStack(spacing: 18) {
                        ProBadge()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                }
                
                SettingsRow(icon: "square-arrow-out-up-right", title: "Terms of Service") {
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .onTapGesture {
                    UIApplication.shared.open(SettingsExternalLink.privacyPolicy.url)
                }
                
                SettingsRow(icon: "square-arrow-out-up-right", title: "Privacy Policy") {
                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .onTapGesture {
                    UIApplication.shared.open(SettingsExternalLink.privacyPolicy.url)
                }
            }
            // NOTE: Pequeño delay para evitar el warning
            // .task {
            //     try? await Task.sleep(for: .milliseconds(100))
            // }
            .navigationDestination(for: SettingsRoute.self) { route in
                routeView(for: route)
                    .onAppear { currentSubView = route }
                    .onDisappear { currentSubView = nil }
            }
            .padding(.horizontal, 12)
            .listStyle(.plain)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(currentSubView != nil)
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    @ViewBuilder
    private func routeView(for route: SettingsRoute) -> some View {
        switch route {
        case .myProfile:     MyProfileDetailView()
        case .myFamily:      MyProfileDetailView()
        case .account:       MyProfileDetailView()
        case .appearance:    MyProfileDetailView()
        case .notifications: MyProfileDetailView()
        }
    }
}

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let trailing: Trailing

    var body: some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.primary.opacity(0.6))
                .frame(width: 22, height: 22)

            Text(title)
                .font(.body.weight(.semibold))
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(1)

            Spacer()

            trailing
        }
        .frame(height: 60)
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .overlay(alignment: .bottom) {
            // Línea punteada manual
            GeometryReader { geo in
                Path { path in
                    let y = geo.size.height
                    var x: CGFloat = 0
                    let dashLength: CGFloat = 3
                    let gapLength: CGFloat = 4

                    while x < geo.size.width {
                        path.move(to: CGPoint(x: x, y: y))
                        path.addLine(to: CGPoint(x: min(x + dashLength, geo.size.width), y: y))
                        x += dashLength + gapLength
                    }
                }
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            }
            .frame(height: 1)
        }
    }
}

struct ProBadge: View {
    var body: some View {
        Text("Pro")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.blue)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .overlay(
                Capsule()
                    .stroke(.blue, lineWidth: 1.5)
            )
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
