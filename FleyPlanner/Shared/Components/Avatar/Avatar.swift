//
//  Avatar.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 12/2/26.
//

import SwiftUI

struct Avatar: View {
    var type: AvatarType
    var size: AvatarSize
    var state: AvatarState
    var customSize: CGFloat? = nil
    
    public var body: some View {
        ZStack {
            switch type {
                case .initials(let text):
                    Text(text)
                        .font(.system(size: size.fontSize, weight: .semibold))
                        .lineLimit(1)
                case .image(let image):
                    AsyncImage(url: image) { phase in
                        switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable().scaledToFit()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Image(systemName: "exclamationmark.triangle")
                            @unknown default:
                                EmptyView()
                        }
                    }
            }
        }
        .frame(width: customSize ?? size.size, height: customSize ?? size.size)
        .background(.white)
        .clipShape(.circle)
        .overlay {
            Circle()
                .stroke(Color.gray).opacity(0.3)
        }
        .overlay(alignment: .topTrailing) {
            if state != .normal {
                AvatarBadge(
                    avatarSizing: size,
                    state: state
                )
                .offset(x: size.offset, y: size.offset)
            }
        }
    }
}

#Preview {
    VStack {
        HStack {
            Avatar(type: .initials(text: "EB"), size: .profile, state: .normal)
            Avatar(type: .initials(text: "EB"), size: .lg, state: .normal)
            Avatar(type: .initials(text: "EB"), size: .md, state: .normal)
            Avatar(type: .initials(text: "EB"), size: .sm, state: .normal)
            Avatar(type: .initials(text: "EB"), size: .xs, state: .normal)
            Avatar(type: .initials(text: "EB"), size: .tiny, state: .normal)
        }
        
        HStack {
            Avatar(type: .image(image: URL(string: "https://i.pravatar.cc/100")!), size: .profile, state: .normal)
            Avatar(type: .image(image: URL(string: "https://i.pravatar.cc/100")!), size: .lg, state: .normal)
            Avatar(type: .image(image: URL(string: "https://i.pravatar.cc/100")!), size: .md, state: .normal)
            Avatar(type: .image(image: URL(string: "https://i.pravatar.cc/100")!), size: .sm, state: .normal)
            Avatar(type: .image(image: URL(string: "https://i.pravatar.cc/100")!), size: .xs, state: .normal)
            Avatar(type: .image(image: URL(string: "https://i.pravatar.cc/100")!), size: .tiny, state: .normal)
        }
        
        HStack {
            Avatar(type: .initials(text: "EB"), size: .profile, state: .offline)
            Avatar(type: .initials(text: "EB"), size: .lg, state: .online)
            Avatar(type: .initials(text: "EB"), size: .md, state: .offline)
            Avatar(type: .initials(text: "EB"), size: .sm, state: .online)
            Avatar(type: .initials(text: "EB"), size: .xs, state: .offline)
            Avatar(type: .initials(text: "EB"), size: .tiny, state: .offline)
        }
        
        HStack {
            Avatar(type: .image(image: URL(string: "https://i.pravatar.cc/100")!), size: .lg, state: .offline)
            Avatar(type: .image(image: URL(string: "https://i.pravatar.cc/100")!), size: .md, state: .online)
            Avatar(type: .image(image: URL(string: "https://i.pravatar.cc/100")!), size: .sm, state: .offline)
            Avatar(type: .image(image: URL(string: "https://i.pravatar.cc/100")!), size: .xs, state: .online)
        }
    }
}
