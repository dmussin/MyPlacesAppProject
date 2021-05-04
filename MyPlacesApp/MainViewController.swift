//
//  MainViewController.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 28.04.2021.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    

    // recieving data from DB
    var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self) //Displaying data from DB. 
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count //If empty return 0 else counts from DB
    }

    // Config cell, setting up name, location, type, image
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2.1
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    
    //MARK: - Table view delegate
    // different options by swiping on left
    
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let place = places[indexPath.row]
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, complete in
//
//            StorageManager.deleteObject(place)
//            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//            complete(true)
//           }
//
//           deleteAction.backgroundColor = .red
//
//           let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
//           configuration.performsFirstActionWithFullSwipe = true
//           return configuration
//       }
//
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//           return true
//       }
//
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in

            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
    }

        return [deleteAction]
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
    // Passing Data between Controllers
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.saveNewPlace()
        tableView.reloadData() // updating interface
        
    }
}

