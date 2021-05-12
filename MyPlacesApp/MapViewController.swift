//
//  MapViewController.swift
//  MyPlacesApp
//
//  Created by Daniyar Mussin on 11.05.2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var place: Place!
    let annotationIdentifier = "annotationIdentifier"// value of annotation
    

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        // calling method setupPlacemark by the transition on ViewController
        setupPlacemark()
    }

    
    
    
    @IBAction func closeVC() {
        dismiss(animated: true, completion: nil) // closing mapVC
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
}
