//
//  MapViewController.swift
//  dsndr
//
//  Created by Brenton Babb on 12/18/20.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var mapView: MKMapView!
    //all this does is show the user's pin on a map
    override func viewDidLoad() {
        super.viewDidLoad()
        let noLocation = CLLocationCoordinate2D()
        let viewRegion = MKCoordinateRegion(center: noLocation, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(viewRegion, animated: false)
        mapView.showsUserLocation = true
        
           let locationManager = CLLocationManager()
           locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyBest

           // Check for Location Services
           if (CLLocationManager.locationServicesEnabled()) {
               locationManager.requestAlwaysAuthorization()
               locationManager.requestWhenInUseAuthorization()
           }

           //Zoom to user location
           if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
               mapView.setRegion(viewRegion, animated: false)
           }
    }
}
