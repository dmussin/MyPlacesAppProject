//
//  MainViewController.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 28.04.2021.
//

import UIKit

class MainViewController: UITableViewController {
    

    // recieving array from PlaceModel.
    let places = Place.getPalces()
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    // Config cell, setting up name, location, type, image
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        cell.nameLabel.text = places[indexPath.row].name
        cell.locationLabel.text = places[indexPath.row].location
        cell.typeLabel.text = places[indexPath.row].type
        
        cell.imageOfPlace.image = UIImage.init(named: places[indexPath.row].name)
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2.1
        cell.imageOfPlace.clipsToBounds = true
        
        return cell
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
    @IBAction func cancelAction(_ segue: UIStoryboardSegue){
        
    }
}
