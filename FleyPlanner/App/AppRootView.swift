//
//  AppRootView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 4/2/26.
//

import SwiftUI

// MARK: - App Root View (Simple)

struct AppRootView: View {
    var body: some View {
        ZStack {
            DashboardView()
                .scrollContentBackground(.hidden)
        }
    }
}
