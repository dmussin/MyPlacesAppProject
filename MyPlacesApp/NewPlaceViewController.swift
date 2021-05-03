//
//  NewPlaceViewController.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 03.05.2021.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    // declaring an example of PLACE
    var newPlace: Place?
    // default image to icon
    var imageIsChanged = false
    

    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hiding empty lines in footer
        
        tableView.tableFooterView = UIView()
        
        // disabling SAVE button until filelds will be completed
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFiledChanged), for: .editingChanged)

}

   // MARK: Table view delegate
    
    // taping on image -> image selector
    // else hiding the keyboard.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            // after tapping on image, action sheet alert appears with the 3 options: Camera, PhotoLib and Cancel.
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.choseImagePicker(source: .camera)
            }
            
            camera.setValue(cameraIcon, forKey: "image") // setting value for key(icon image)
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment") // text to the left.
            
            let photo = UIAlertAction(title: "Photo Library", style: .default) { _ in
                self.choseImagePicker(source: .photoLibrary)
                
            }
            
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    
    // creating a method for save button action
    func saveNewPlace(){
        
        // setting up image to default or that will be chosen
        var image: UIImage?
        
        if imageIsChanged{
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
        newPlace = Place(name: placeName.text!,
                         location: placeLocation.text,
                         type: placeType.text,
                         image: image,
                         restaurantImage: nil)
    }
    
    
    // Cancel button action
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}

// MARK: Text field delegate

extension NewPlaceViewController: UITextFieldDelegate {

//Hiding keyboard after pressing "done"

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFiledChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}


// MARK: Work with image
extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // setting up source for ImagePickerController
    func choseImagePicker(source: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self // setting delegate for image selection to class
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    
    // picking image and changing the black image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChanged = true //
        
        dismiss(animated: true, completion: nil)
    }
    
}
