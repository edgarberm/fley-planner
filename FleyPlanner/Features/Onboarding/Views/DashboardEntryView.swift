//
//  DashboardEntryView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import SwiftUI

struct DashboardEntryView: View {
    
    @Environment(AppState.self) private var appState
    
    var body: some View {
        Color.clear
            .task {
                appState.completeOnboarding()
            }
    }
}

#Preview {
    DashboardEntryView()
}
