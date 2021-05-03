//
//  PlaceModel.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 29.04.2021.
//

import UIKit

struct Place {
    
    var name: String
    var location: String?
    var type: String?
    var image: UIImage?
    var restaurantImage: String?
 
    
      static let restaurantNames = [
            "Yami Sushi", "Saigon", "Kebab King",
            "Brux", "Letnanska Terasa", "KFC", "Burger King",
            "Tavern", "Tom's Burger", "Kantyna", "Chilli and Lime",
            "Potrefena Husa"
        ]
    
    
    // method which generates test names from restourantNames
   static func getPalces()-> [Place] {
        
        var places = [Place]()
        
        for place in restaurantNames {
            places.append(Place(name: place, location: "Prague", type: "Restaurant", image: nil, restaurantImage: place))
        }
        
        
        return places
    }
    
}
