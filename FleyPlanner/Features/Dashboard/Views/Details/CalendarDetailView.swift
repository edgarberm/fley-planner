//
//  CalendarDetailView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 10/2/26.
//

import SwiftUI

struct CalendarDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "calendar")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                
                Text("Calendar Detail")
                    .font(.largeTitle.bold())
                
                Text("Your events will appear here")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    CalendarDetailView()
}
