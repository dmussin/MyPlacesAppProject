//
//  NewPlaceViewController.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 03.05.2021.
//

import UIKit
import Cosmos

class NewPlaceViewController: UITableViewController {

    var currentPlace: Place! // creating an object for segue navigation (editing a record)
    var imageIsChanged = false   // default image to icon
    var currentRating = 0.0 // var for rating(cosmos)
    

    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var cosmosView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // hiding empty lines in footer
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        
        // disabling SAVE button until filelds will be completed
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFiledChanged), for: .editingChanged)

        // calling method setupEditScreen
        setupEditScreen()
        
        // Cosmos framework init
        cosmosView.settings.fillMode = .half
        cosmosView.didTouchCosmos = {
            rating in self.currentRating = rating
        }
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
    
    
    // MARK: Navigation
    
    // Method for map
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier,
              let mapVC = segue.destination as? MapViewController
        else { return }
        
        mapVC.incomeSegueIdentifier = identifier
        
        if identifier == "showPlace" {
        mapVC.place.name = placeName.text!
        mapVC.place.location = placeLocation.text
        mapVC.place.type = placeType.text
        mapVC.place.imageData = placeImage.image?.pngData()
    }
    }
    
    
    // creating a method for save button action
    func savePlace(){
        
        // setting up image to default or that will be chosen
        let image = imageIsChanged ? placeImage.image : #imageLiteral(resourceName: "imagePlaceholder")
        
        //Converting type image to Data.
        let imageData = image?.pngData()
        
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text!,
                             type: placeType.text!,
                             imageData: imageData,
                             rating: currentRating)
        
        // checking mode creation or editing
        if currentPlace != nil {
            try! realm.write { //Updating the record.
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        } else {
        StorageManager.saveObject(newPlace ) // saving object in DB
    }
}
    
    // setting currentPlace data to outlets after recieveing object from DB
    private func setupEditScreen() {
        if currentPlace != nil {
            
            setUpNavigationBar()
            
            imageIsChanged = true // stopping change the image to default during editing 
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            cosmosView.rating = currentPlace.rating // showing sorting rating
        }
    }
    
    
    // Navigation Bar - Back Button instead of Cancel.
    private func setUpNavigationBar(){
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // Changing NavigationBar Button Name and Style.
        }
        
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
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
