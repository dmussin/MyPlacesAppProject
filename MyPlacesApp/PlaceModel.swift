//
//  PlaceModel.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 29.04.2021.
//

import RealmSwift

class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
   // var restaurantImage: String?
 
    
       let restaurantNames = [
            "Yami Sushi", "Saigon", "Kebab King",
            "Brux", "Letnanska Terasa", "KFC", "Burger King",
            "Tavern", "Tom's Burger", "Kantyna", "Chilli and Lime",
            "Potrefena Husa"
        ]
    
    
    // method which generates test names from restourantNames
    func savePlaces() {
        
        for place in restaurantNames {
            
            
           let image = UIImage(named: place)
           guard let imageData = image?.pngData() else { return } // convertion to type Data for Realm
            
           let newPlace = Place()
            
            newPlace.name = place
            newPlace.location = "Prague"
            newPlace.type = "Restaurant"
            newPlace.imageData = imageData
            
            StorageManager.saveObject(newPlace)
        }
    }
    
}
