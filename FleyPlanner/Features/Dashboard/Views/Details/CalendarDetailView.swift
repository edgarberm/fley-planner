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
        ZStack {
            // Material de fondo
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
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
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.blue.opacity(0.01))
    }
}


#Preview {
    CalendarDetailView()
}
