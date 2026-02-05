//
//  Utils.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import SwiftUI

func createfamilyInviteCode(_ familyId: String) -> String {
    let hex = familyId.replacingOccurrences(of: "-", with: "")
    // Tomamos los primeros 8 caracteres y ponemos guion en el medio
    let first = hex.prefix(4)
    let second = hex.dropFirst(4).prefix(4)
    return "\(first)-\(second)".uppercased()
}

func displayCornerRadius(for screen: UIScreen = .main) -> CGFloat {
    guard let value = screen.value(forKey: "_displayCornerRadius") as? CGFloat else {
        return 0
    }
    return value
}
