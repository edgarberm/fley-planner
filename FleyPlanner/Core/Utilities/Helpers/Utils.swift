//
//  Utils.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 1/2/26.
//

import Foundation

func createfamilyInviteCode(_ familyId: String) -> String {
    let hex = familyId.replacingOccurrences(of: "-", with: "")
    // Tomamos los primeros 8 caracteres y ponemos guion en el medio
    let first = hex.prefix(4)
    let second = hex.dropFirst(4).prefix(4)
    return "\(first)-\(second)".uppercased()
}
