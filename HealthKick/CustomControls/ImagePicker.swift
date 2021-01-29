//
//  ImagePickerView.swift
//  HealthKick
//
//  Created by Patrick Genevich on 6/12/20.
//  Copyright © 2020 Patrick Genevich. All rights reserved.
//

import SwiftUI

final class ImagePickerCoordinator: NSObject {
    @Binding var image: UIImage?
    @Binding var takePhoto: Bool

    init(image: Binding<UIImage?>, takePhoto: Binding<Bool>) {
        _image = image
        _takePhoto = takePhoto
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var takePhoto: Bool

    func makeCoordinator() -> ImagePickerCoordinator {
        ImagePickerCoordinator(image: $image, takePhoto: $takePhoto)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.delegate = context.coordinator
        return pickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        switch self.takePhoto {
        case true:
            uiViewController.sourceType = .camera
            uiViewController.showsCameraControls = true
        case false:
            uiViewController.sourceType = .photoLibrary
        }
        uiViewController.allowsEditing = false
    }
}

extension ImagePickerCoordinator: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let imageOriginal = info[.originalImage] as? UIImage {
//            image = imageOriginal
            image = resizeImage(image: imageOriginal)
        }
        if let imageEdited = info[.editedImage] as? UIImage {
            image = imageEdited
        }

        picker.dismiss(animated: true, completion: nil)
    }

    func resizeImage(image: UIImage) -> UIImage {
        let width = image.size.width
        let height = image.size.height
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
