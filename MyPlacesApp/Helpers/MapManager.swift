//
//  MapManager.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 21/05/2021.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager() // User location manager
    
    private let regionInMetters =  1000.00 // Region Value for MKCoordinateRegion
    private var directionsArray: [MKDirections] = [] // Array for directions (for canceling when starting new route after the position change)
    private var placeCoordinate: CLLocationCoordinate2D? // coordinates
    
    
    // marker that shows location of the place.
     func setupPlacemark(place: Place, mapView: MKMapView){
        guard let location = place.location else { return }
        let geocoder = CLGeocoder() // transform geodata to undestandable format
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            // Mark description
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            
            // connecting annotation to mark on map
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate // transfering coordinates to placeCoordinate
            
            // setting point of view to makee all annotation visible
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true) // selecting annotation
        }
    }
    
    // Cheking in location services are enabled
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIndetifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.showAlert(
                    title: "Location Services Are Disabled 🚫",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn it On 🧐")
            }
        }
    }
    
    
    // Method for checking if location was acepted
     func checkLocationAuthorization(mapView: MKMapView, segueIndetifier: String) {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIndetifier == "getAddress" { showUserLocation(mapView: mapView) } //calling method showUserLocation
            break
        case .restricted, .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.showAlert(
                    title: "Your Location is not Available 📍",
                    message: "To give a permission go to: Settings -> MyPlacesApp -> Location 👀")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    // Method fokusing on user location
     func showUserLocation(mapView: MKMapView){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMetters,
                                            longitudinalMeters: regionInMetters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //Method for navigation logic
     func getDirections(mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        // getting user location
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current Location is Not Found")
            return
        }
        
        locationManager.startUpdatingLocation() // tracking location
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionRequest(from: location) //current user location as a value
        else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)  //creating a route
        resetMapView(withNew: directions, mapView: mapView) // deleting the routes
        
        directions.calculate { (response, error) in // Route calculation
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Direction is not available")
                return
            }
            
            // Object response contain array route with the routes
            // Sorting out the array
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) // Whole route is visible
                let distance = String(format: "%.1f", route.distance / 1000) // Distance
                let timeInterval = String(format: "%.1f", route.expectedTravelTime / 60)
                
                }
            }
        }
    
    
    //Method for request for creation a route
     func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)  // start location
        let destination = MKPlacemark(coordinate: destinationCoordinate) // destination location
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        
        // alernative route
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    
    // Method tracking user location
     func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()){
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.showUserLocation()
        closure(center)
        }
    
    
// Method for reseting MapView
 func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
    mapView.removeOverlays(mapView.overlays) // removing overlays on map
    directionsArray.append(directions) // adding direction to Array
    let _ = directionsArray.map {$0.cancel()}// reseting a route
    directionsArray.removeAll()
}
    
// Method getting coordinates from map positioning
 func getCenterLocation(for mapView: MKMapView) -> CLLocation {
    let latitude = mapView.centerCoordinate.latitude
    let longitude = mapView.centerCoordinate.longitude
    
    return CLLocation(latitude: latitude, longitude: longitude)
}

    // Alert Controller
     func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        // Creating object UIWindow and init rootViewController - after we can call present.
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1 // positioning window over other windows
        alertWindow.makeKeyAndVisible() // alertWindow visible
        alertWindow.rootViewController?.present(alert, animated: true) // calling windows as an alert
        
        
    
    }
    
}
