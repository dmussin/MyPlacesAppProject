//
//  CustomTableViewCell.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 29.04.2021.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imageOfPlace: UIImageView!{
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2.1 // rounded images
            imageOfPlace.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!{
    didSet {
        cosmosView.settings.updateOnTouch = false // stars are un mutable on main screen. 
    }
  }
}
