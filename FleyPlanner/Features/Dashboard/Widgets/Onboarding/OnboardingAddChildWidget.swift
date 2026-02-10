//
//  OnboardingAddChildWidget.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 9/2/26.
//

import SwiftUI

struct OnboardingAddChildWidget: View {
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(.blue)
            
            Text("Add your first child")
                .font(.headline)
            
            Text("Start organizing your family")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
//            Button {
//                onTap()  // ← Ejecutar callback
//            } label: {
//                Text("Add Child")
//                    .font(.subheadline.bold())
//                    .frame(maxWidth: .infinity)
//            }
//            .buttonStyle(.borderedProminent)
//            .controlSize(.small)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onTapGesture {
            onTap()
        }
    }
}
