//
//  MainViewController.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 28.04.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Search Controller - nil, because we want to transver data to the same view that we using
   private let searchController = UISearchController(searchResultsController: nil)
    // recieving data from DB
   private var places: Results<Place>!
    // Ascending sorting
   private var ascendingSorting = true
    // Filter
   private var filtredPlaces: Results<Place>!
   private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    // tracking searhing request
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        places = realm.objects(Place.self) //Displaying data from DB.
        
        // Setup the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false // Interacting with the VC
        searchController.searchBar.placeholder = "Search" // name for search bar
        navigationItem.searchController = searchController // integrating search bar to the navigation bar
        definesPresentationContext = true // hiding when moving to other screen
    }

    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if isFiltering true - returning results from array
        if isFiltering {
            return filtredPlaces.count
        }
        return places.isEmpty ? 0 : places.count //If empty return 0 else counts from DB
    }

    // Config cell, setting up name, location, type, image
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        var place = Place()
        
        // if filtered - showing results else data from DB.
        if isFiltering {
            place = filtredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2.1
        cell.imageOfPlace.clipsToBounds = true

        return cell
    }
    
    
    //MARK: - Table view delegate
    
    // unmarking line after selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // different options by swiping on left
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in

            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
    }

        return [deleteAction]
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return } // getting current index for selected row.
            
            let place: Place
            if isFiltering {
                place = filtredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place // send object to NewPlaceViewControler
        }
    }
    
    
    // Passing Data between Controllers
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue){
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData() // updating interface
    }
    
    // Sorting by name / date while using sender control.
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        
       sorting() // calling sorting method
    }
    
    // Ascending sorting button image change
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
          
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reversedSortingButton.image = UIImage(systemName: "arrowtriangle.down.fill")
        } else {
            reversedSortingButton.image = UIImage(systemName: "arrowtriangle.up.fill")
        }
        
        sorting() // calling sorting method
    }
    
    // Ascending sorting method
    private func sorting() {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!) // value from searchbar text
    }
    
    // Filtering the content
    private func filterContentForSearchText(_ searchText: String) {
        filtredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
}
