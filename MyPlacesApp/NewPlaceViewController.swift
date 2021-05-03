//
//  NewPlaceViewController.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 03.05.2021.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hiding empty lines in footer
        
        tableView.tableFooterView = UIView()

}

   // MARK: Table view delegate
    
    // taping on image -> image selector
    // else hiding the keyboard.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        } else {
            view.endEditing(true)
        }
    }

}

// MARK: Text field delegate

extension NewPlaceViewController: UITextFieldDelegate {

//Hiding keyboard after pressing "done"

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
