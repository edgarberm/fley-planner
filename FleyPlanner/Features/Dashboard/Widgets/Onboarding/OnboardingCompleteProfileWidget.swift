//
//  OnboardingCompleteProfileWidget.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 9/2/26.
//

import SwiftUI

struct OnboardingCompleteProfileWidget: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            
            Text("Complete your profile")
                .font(.headline)
            
            Text("Add avatar & address")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                // TODO: Navigate to profile
                print("🎯 Complete profile tapped")
            } label: {
                Text("Complete")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
