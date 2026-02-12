//
//  ChildrenDetailView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 10/2/26.
//

import SwiftUI

struct ChildrenDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                
                Text("Children Detail")
                    .font(.largeTitle.bold())
                
                Text("Add your first child to get started")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
                Button("Add Child") {
                    // TODO: Add child
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    ChildrenDetailView()
}
