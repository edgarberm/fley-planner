//
//  ToolbarItemBackButton.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 13/2/26.
//

import SwiftUI

struct ToolbarItemBackButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Botón flotante
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    .gray.opacity(0.3),
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                )
        }
    }
}

#Preview {
    ToolbarItemBackButton()
}
