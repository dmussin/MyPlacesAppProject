//
//  MapViewController.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 11.05.2021.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"// value of annotation
    let locationManager = CLLocationManager() // User location manager
    let regionInMetters =  20_000.00 // Region Value for MKCoordinateRegion
    var incomeSegueIdentifier = "" // Depend on the value different method can be called (showUserLocation)
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
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
    
    @IBAction func doneButtonPressed() {
    }
    
    // calling method setupPlacemark by the transition on ViewController if segue is showPlace
    private func setupMapView(){
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true // hiding PinImage Marker if segue is showPlace
            addressLabel.isHidden = true // hiding Adress Label
            doneButton.isHidden = true // hiding Done Button
        }
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
            if incomeSegueIdentifier == "getAdress" { showUserLocation() } //calling method showUserLocation
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
    
    
    // Method for showing user location
    private func showUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMetters,
                                            longitudinalMeters: regionInMetters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    // Method getting coordinates from map positioning
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
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
    
    
}

// Protocol and method for displaying current position.
extension MapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
