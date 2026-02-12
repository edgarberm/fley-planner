//
//  AvatarModels.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 12/2/26.
//

import SwiftUI

public enum AvatarType {
    case initials(text: String)
    case image(image: URL)
}

enum AvatarSize {
    case tiny, xs, sm, md, lg, profile
    
    var size: CGFloat {
        switch self {
            case .tiny: 28
            case .xs: 32
            case .sm: 40
            case .md: 48
            case .lg: 56
            case .profile: 80
        }
    }
    
    var fontSize: CGFloat {
        switch self {
            case .tiny: return 10
            case .xs: return 12
            case .sm: return 14
            case .md: return 18
            case .lg: return 20
            case .profile: return 32
        }
    }
    
    var badgeSize: CGFloat {
        switch self {
            case .tiny: return 10
            case .xs: return 12
            case .sm: return 14
            case .md: return 16
            case .lg, .profile: return 18
        }
    }
    
    var badgeTextSize: CGFloat {
        switch self {
            case .tiny: return 6
            case .xs, .sm: return 8
            case .md, .lg, .profile: return 12
        }
    }
    
    var offset: CGFloat {
        switch self {
            case .tiny, .xs: return 1
            default: return 3
        }
    }
}

public enum AvatarState {
    case normal, online, offline
    
    var bgColor: Color {
        switch self {
            case .online: return .green
            case .offline: return .pink
            default: return .clear
        }
    }
}
