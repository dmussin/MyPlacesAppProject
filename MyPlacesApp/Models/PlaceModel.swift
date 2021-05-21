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
    @objc dynamic var date = Date() // for sorting
    @objc dynamic var rating = 0.0 // for rating
    
    // initialization for class 
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
        
    }
}
