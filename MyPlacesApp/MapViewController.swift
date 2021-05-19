//
//  MapViewController.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 11.05.2021.
//

import UIKit
import MapKit
import CoreLocation

// Creating protocol for transfering data from MapViewController to NewPlaceViewController
protocol MapViewControllerDelegate {
   func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier"// value of annotation
    let locationManager = CLLocationManager() // User location manager
    let regionInMetters =  1000.00 // Region Value for MKCoordinateRegion
    var incomeSegueIdentifier = "" // Depend on the value different method can be called (showUserLocation)
    var placeCoordinate: CLLocationCoordinate2D? // coordinates
    var directionsArray: [MKDirections] = [] // Array for directions (for canceling when starting new route after the position change)
    // property for storing previous Location
    var previousLocation: CLLocation? {
        didSet {
    startTrackingUserLocation()
     }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        // calling method setupMapView
        setupMapView()
        
        // Request for location autorization
        checkLocationAuthorization()
        
        addressLabel.text = ""
    }
    
    // Center location for user button
    @IBAction func centerViewForUserLocation() {
      showUserLocation()
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true, completion: nil) // closing mapVC
    }
    @IBAction func goButtonPressed() {
       getDirections()
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text) // sending to param getAddress - current address
        dismiss(animated: true) // Closing VC 
    }
    
    // calling method setupPlacemark by the transition on ViewController if segue is showPlace
    private func setupMapView(){
        
        goButton.isHidden = true
        distanceLabel.isHidden = true
        timeLabel.isHidden = true
        
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true // hiding PinImage Marker if segue is showPlace
            addressLabel.isHidden = true // hiding Adress Label
            doneButton.isHidden = true // hiding Done Button
            goButton.isHidden = false
           
        }
    }
    
    // Method for reseting MapView
    private func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays) // removing overlays on map
        directionsArray.append(directions) // adding direction to Array
        let _ = directionsArray.map {$0.cancel()}// reseting a route
        directionsArray.removeAll()
        
        
    }
    
    
    // marker that shows location of the place.
    private func setupPlacemark(){
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
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            
            // connecting annotation to mark on map
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate // transfering coordinates to placeCoordinate
            
            // setting point of view to makee all annotation visible
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true) // selecting annotation
            
            
        }
    }
    
    // Cheking in location services are enabled
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.showAlert(
                    title: "Location Services Are Disabled 🚫",
                    message: "To enable it go: Settings -> Privacy -> Location Services and turn it On 🧐")
            }
        }
    }
    
    private func setupLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // accuracy of positioning
        locationManager.delegate = self // method and protocol will perform mapViewController
    }
    
    // Method for checking if location was acepted
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" { showUserLocation() } //calling method showUserLocation
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
    
    
    // Method showing user location
    private func showUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMetters,
                                            longitudinalMeters: regionInMetters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Method tracking user location
    private func startTrackingUserLocation(){
        guard let previousLocation = previousLocation else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
    }
    
    
    // Method getting coordinates from map positioning
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    //Method for navigation logic
    private func getDirections() {
        // getting user location
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current Location is Not Found")
            return
        }
        
        locationManager.startUpdatingLocation() // tracking location
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        guard let request = createDirectionRequest(from: location) //current user location as a value
        else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)  //creating a route
        resetMapView(withNew: directions) // deleting the routes
        
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
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) // Whole route is visible
                let distance = String(format: "%.1f", route.distance / 1000) // Distance
                let timeInterval = String(format: "%.1f", route.expectedTravelTime / 60)
                
                self.distanceLabel.isHidden = false
                self.timeLabel.isHidden = false
                
                self.distanceLabel.text = "Distance: \(distance) km"
                self.timeLabel.text = "Travel time: \(timeInterval) Min"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.distanceLabel.isHidden = true
                    self.timeLabel.isHidden = true
                }
            }
        }
    }
    
    //Method for request for creation a route
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
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
    
    // Alert Controller
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    
    
}

// Pin with banner in Maps.
extension MapViewController: MKMapViewDelegate{
    // displaying annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // my current position
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView // coercion to PIN on map
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true   // Annotation in the form of banner
        }
        
        // Placing image on banner
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView // displaying image 
        }
        return annotationView
    }
    
    // changing coordinates to adress
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        // automatic fokusing on user current location
        if incomeSegueIdentifier  == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation()
            }
        }
        
        // optimizing resources - canceling deffered requests
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline) // rendered superposition
        renderer.strokeColor = .orange
        
        return renderer
    }
    
}

// Protocol and method for displaying current position.
extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
