//
//  AvatarBadge.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 12/2/26.
//

import SwiftUI

struct AvatarBadge: View {
    var avatarSizing: AvatarSize
    var state: AvatarState
    
    public var body: some View {
        Circle()
            .fill(state.bgColor)
            .frame(width: avatarSizing.badgeSize, height: avatarSizing.badgeSize)
            .overlay {
                Circle()
                    .stroke(.white, lineWidth: 2)
            }
    }
}

#Preview {
    AvatarBadge(avatarSizing: .lg, state: .offline)
}
