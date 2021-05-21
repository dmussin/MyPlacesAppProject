//
//  StorageManager.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 03.05.2021.
//


//  Realm 
import RealmSwift

// Creating a method for adding to DB
let realm = try! Realm()

class StorageManager {
    static func saveObject(_ place: Place) {
        try! realm.write{
            realm.add(place)
        }
    }
    
    
    // method for deleting object from DB
    static func deleteObject(_ place: Place){
        try! realm.write{
            realm.delete(place)
        }
    }
    
}

