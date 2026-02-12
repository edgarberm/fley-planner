//
//  SettingsView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 11/2/26.
//

import SwiftUI

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    Text("Hello \(appState.currentUser?.name ?? "Anonymous")")
                    
                    ForEach(0..<100) { _ in
                        Text("Some text goes here")
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

//#Preview {
//    SettingsView()
//}
