//
//  AvatarPicker.swift
//  FleyPlanner
//
//  Created by Edgar Bermejo on 17/2/26.
//

import SwiftUI

enum ImageSourceType: String, Identifiable {
    var id: String { self.rawValue }
    
    case camera
    case photoLibrary
}

struct AvatarPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    let imageSourceType: ImageSourceType
    
    @Binding var selectedImage: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, selectedImage: $selectedImage)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        
        switch imageSourceType {
            case .camera:
                picker.sourceType = .camera
                picker.cameraCaptureMode = .photo
            case .photoLibrary:
                picker.mediaTypes = ["public.image"]
                picker.sourceType = .photoLibrary
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    typealias UIViewControllerType = UIImagePickerController
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: AvatarPicker
        
        @Binding var selectedImage: UIImage?
        
        init(parent: AvatarPicker, selectedImage: Binding<UIImage?>) {
            self.parent = parent
            self._selectedImage = selectedImage
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                self.selectedImage = image
            } else if let image = info[.originalImage] as? UIImage {
                self.selectedImage = image
            }
            
            parent.dismiss()
        }
    }
}
