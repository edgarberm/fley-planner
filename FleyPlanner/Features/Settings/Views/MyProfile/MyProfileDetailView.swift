//
//  MyProfileDetailView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 13/2/26.
//

import SwiftUI

struct MyProfileDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                Text("You are into detail view")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button {
                    showImagePicker.toggle()
                } label: {
                    Avatar(type: .image(image: URL(string: "https://i.pravatar.cc/100")!), size: .profile, state: .normal)
                }
                .sheet(isPresented: $showImagePicker) {
                    AvatarPicker(imageSourceType: .camera, selectedImage: $selectedImage)
                        .ignoresSafeArea()
                }
            
                ForEach(0..<50) { index in
                        Text("Item text too long goes here for the index: \(index + 1)")
                }
                
                Spacer()
            }
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ToolbarItemBackButton()
            }
            .hideSharedBackgroundIfAvailable()
        }
        .background(Color(UIColor.secondarySystemBackground))
        .background {
            SwipeBackEnabler()
        }
    }
}

#Preview {
    MyProfileDetailView()
}
