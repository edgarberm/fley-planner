//
//  AppRootView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 4/2/26.
//

import SwiftUI

// MARK: - App Root View (Simple)

struct AppRootView: View {
    @Environment(AppState.self) private var appState
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        ZStack {
            DashboardView()
                .scrollContentBackground(.hidden)
        }
    }
}
