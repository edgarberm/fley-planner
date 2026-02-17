//
//  EditAvatarView.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 17/2/26.
//

import SwiftUI

struct EditAvatarView<Label: View>: View {
    @Binding var selectedImage: UIImage?
    @ViewBuilder var label: () -> Label
    
    @State private var isConfirmationDialogPresented: Bool = false
    @State private var selectedImageSourceType: ImageSourceType?
    
    var body: some View {
        Button {
            isConfirmationDialogPresented.toggle()
        } label: {
            label()
        }
        .buttonStyle(.plain)
        .confirmationDialog("Choose an image", isPresented: $isConfirmationDialogPresented) {
            
            Button("Camera") {
                selectedImageSourceType = .camera
            }
            Button("Library") {
                selectedImageSourceType = .photoLibrary
            }
            Button("Cancel", role: .cancel) {
                
            }
        }
        .sheet(item: $selectedImageSourceType) { sourceType in
            AvatarPicker(imageSourceType: sourceType, selectedImage: $selectedImage)
                .ignoresSafeArea()
        }
    }
}

//#Preview {
//    EditAvatarView()
//}
