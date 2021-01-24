//
//  ViewController.swift
//  dsndr
//
//  Created by Brenton Babb on 12/18/20.
//

import UIKit
import Foundation
import CoreLocation
import CoreFoundation

class DashboardViewController: UIViewController {
    @IBOutlet var altitudeLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    
    var ride: Ride!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        seconds = 0
        //sets intial disatnce to 0 and is using miles as units
        distance = Measurement(value: 0, unit: UnitLength.meters)
        //makes sure the location array is empty (deletes users previous ride)
        locationList.removeAll()
        //updates values on screen
        updateDisplay()
        //assigns the timner var a Timer with the refresh inverval of 1 second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
          self.eachSecond()
        }
        startLocationUpdates()

        
    }

    //after timer updates adds one second to seconds
    func eachSecond() {
        seconds += 1
        //used to update the screen with most current info
        updateDisplay()
    }
    
    private func updateDisplay() {
        let formattedDistance = Formatting.distance(distance)
        let formattedTime = Formatting.time(seconds)
        //changes distanceLabel to show current distance
        distanceLabel.text = formattedDistance
    
        //changes timeLabel to show current time
        timeLabel.text = formattedTime
    }
    
    private func startLocationUpdates() {
        //locationManger needs a delegate before it can run. Assigned to it's self
        locationManager.delegate = self
        //locationManger has a nice activity type built in. It stops location services when the user is inside or not moving to save battery life
        locationManager.activityType = .fitness
        //min distance in meters (default value) in order for the program to warrent a location update. (nice battery saver)
        locationManager.distanceFilter = 0
        //calls locationManger and starts to track location using apples CoreLocation library
        locationManager.startUpdatingLocation()
    }

}


//This is a facy location updater. I did not write this myself, but I understand how it works. I was having some issues getting this to work on my own, so I turned to the saviors of any programmers career, the stack overflow people
extension DashboardViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = (distance + Measurement(value: delta, unit: UnitLength.meters))
            }
            
            locationList.append(newLocation)
        }
    }
}



