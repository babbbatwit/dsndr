//
//  ViewController.swift
//  dsndr
//
//  Created by Brenton Babb on 12/18/20.
//

import UIKit
import CoreLocation


class DashboardViewController: UIViewController {
    @IBOutlet var altitudeLabel: UILabel!
       
    @IBOutlet var distanceLabel: UILabel!
    
    private let locationManager = CLLocationManager()
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
           locationManager.requestWhenInUseAuthorization()
           locationManager.distanceFilter = kCLDistanceFilterNone
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.startUpdatingLocation()
           locationManager.delegate = self

       }
    
    
    func totalDistance(of locations: [CLLocation]) -> CLLocationDistance {
        var distance: CLLocationDistance = 0.0
        var previousLocation: CLLocation?
        
        locations.forEach { location in
            if let previousLocation = previousLocation {
                distance += location.distance(from: previousLocation)
            }
            previousLocation = location
        }
        
        return distance
    }
}

extension DashboardViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let altitude = lastLocation.altitude
            altitudeLabel.text = "Altitude: \(altitude)"
        }
        
        var distance: CLLocationDistance = 0.0
        var previousLocation: CLLocation?
        
        locations.forEach { location in
            if let previousLocation = previousLocation {
                distance += location.distance(from: previousLocation)
            }
            previousLocation = location
        }
        
        distanceLabel.text = "Distance: \(distance)"
    }
}
    
    

