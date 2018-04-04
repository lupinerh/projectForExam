//
//  PhotoPicker.swift
//  project
//
//  Created by Stanislav Korolev on 01.03.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit


extension MyPhotoController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
   @objc func handleSelectMyImageView() {
        print("image select")
        let picker = UIImagePickerController()
        
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPiker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPiker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPiker = originalImage
        }
        
        if let selectedImage = selectedImageFromPiker {

            myImageView.layer.masksToBounds = true
            myImageView.image = selectedImage
            self.placeholderLabel.text = ""
            
            
            // запуск анализа изображения
            guard let ciImage = CIImage(image: myImageView.image!) else {
                fatalError("couldn't convert UIImage to CIImage")
            }
            
           detectScene(image: ciImage)
            
        }
        
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}


