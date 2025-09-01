//
//  ImagePicker.swift
//  ProofTracker
//
//  Created by Samuel Bortolin on 29/08/25.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        
        // Add camera configuration to reduce warnings
        if sourceType == .camera {
            picker.cameraCaptureMode = .photo
            picker.cameraDevice = .rear
            picker.cameraFlashMode = .auto
            
            // Check if camera is available
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {
                print("⚠️ Camera is not available on this device")
            }
        }
        
        // Use modern presentation style
        picker.modalPresentationStyle = .fullScreen
        
        print("📱 ImagePicker created with source type: \(sourceType.rawValue)")
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
            print("🔧 ImagePicker Coordinator created")
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            print("📸 ImagePicker didFinishPickingMediaWithInfo called")
            
            if let editedImage = info[.editedImage] as? UIImage {
                print("✂️ Using edited image")
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                print("📷 Using original image")
                parent.selectedImage = originalImage
            } else {
                print("❌ No image found in info")
            }
            
            print("🔄 Dismissing ImagePicker")
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            print("❌ ImagePicker cancelled by user")
            parent.dismiss()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFailWithError error: Error) {
            print("💥 ImagePicker failed with error: \(error.localizedDescription)")
            
            // Show error alert to user using modern approach
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Camera Error",
                    message: "Failed to access camera: \(error.localizedDescription)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.parent.dismiss()
                })
                
                // Use modern window scene approach
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController?.present(alert, animated: true)
                }
            }
        }
    }
}
