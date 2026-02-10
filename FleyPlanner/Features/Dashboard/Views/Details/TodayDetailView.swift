//
//  TodayDetailView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 10/2/26.
//

import SwiftUI

struct TodayDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)
                
                Text("Today Detail")
                    .font(.largeTitle.bold())
                
                Text("Complete your profile to see your daily summary")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Complete Profile") {
                    // TODO: Navigate to profile
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

//#Preview {
//    TodayDetailView()
//}
