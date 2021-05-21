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
    
    var mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier"// value of annotation
    var incomeSegueIdentifier = "" // Depend on the value different method can be called (showUserLocation)
    var directionsArray: [MKDirections] = [] // Array for directions (for canceling when starting new route after the position change)
    // property for storing previous Location
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(
                for: mapView,
                and: previousLocation) { (currentLocation) in
                
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
                
            }
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
    
        addressLabel.text = ""
    }
    
    // Center location for user button
    @IBAction func centerViewForUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true, completion: nil) // closing mapVC
    }
    @IBAction func goButtonPressed() {
        mapManager.getDirections(mapView: mapView) { (location) in
            self.previousLocation = location
        }
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
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true // hiding PinImage Marker if segue is showPlace
            addressLabel.isHidden = true // hiding Adress Label
            doneButton.isHidden = true // hiding Done Button
            goButton.isHidden = false
           
        }
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
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        // automatic fokusing on user current location
        if incomeSegueIdentifier  == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
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
        mapManager.checkLocationAuthorization(mapView: mapView, segueIndetifier: incomeSegueIdentifier)
    }
}
