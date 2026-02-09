//
//  OnboardingInvitePartnerWidget.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 9/2/26.
//

import SwiftUI

struct OnboardingInvitePartnerWidget: View {
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 40))
                .foregroundStyle(.green)
            
            Text("Invite your partner")
                .font(.headline)
            
            Text("Share family access")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showShareSheet = true
            } label: {
                Text("Invite")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .sheet(isPresented: $showShareSheet) {
            // TODO: Share sheet con invite code
            Text("Share invite code - TODO")
        }
    }
}
