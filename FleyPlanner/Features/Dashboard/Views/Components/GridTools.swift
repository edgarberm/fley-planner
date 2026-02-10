//
//  GridTools.swift
//  Dotlock
//
//  Created by Edgar Bermejo on 6/8/25.
//

import SwiftUI

struct GridTools: View {
    @Environment(WidgetGridModel.self) var model
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Button(action: {
                    print("Left tapped")
                }) {
                    Image("settings-2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.black)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 6)
            .padding(.horizontal, 36)
        }
    }
}

#Preview {
    GridTools()
}
