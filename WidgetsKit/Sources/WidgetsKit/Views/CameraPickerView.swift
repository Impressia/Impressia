//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
struct CameraPickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var isPresented
    @Binding var selectedImage: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let picker: CameraPickerView

        init(picker: CameraPickerView) {
            self.picker = picker
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let selectedImage = info[.originalImage] as? UIImage else {
                return
            }

            self.picker.selectedImage = selectedImage
            self.picker.isPresented.wrappedValue.dismiss()
        }
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator

        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(picker: self)
    }
}
