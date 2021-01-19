//
//  ViewController.swift
//  dsndr
//
//  Created by Brenton Babb on 12/18/20.
//

import UIKit
import CoreLocation
import CoreFoundation

class DashboardViewController: UIViewController {
    @IBOutlet var altitudeLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    var counter = 0.0
    //var timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UpdateTimer()), userInfo: nil, repeats: true)
    var isPlaying = false

    
    let locationManager = CLLocationManager()
    


    
       override func viewDidLoad() {
           super.viewDidLoad()
           
        timeLabel.text = String(counter)
        
           locationManager.requestWhenInUseAuthorization()
           locationManager.distanceFilter = kCLDistanceFilterNone
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.startUpdatingLocation()
           locationManager.delegate = self

       }
    
    
    
func UpdateTimer() {
    counter = counter + 0.1
    timeLabel.text = String(format: "%.1f", counter)
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
    
    
