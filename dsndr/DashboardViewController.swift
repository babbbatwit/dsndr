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
    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var resumeButton: UIButton!
    
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var duration: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var altitude = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    private var wasPaused = false
    
    var ride: Ride!
    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton.isHidden = true
        pauseButton.isHidden = true
        resumeButton.isHidden = true
        
    }
    
    @IBAction func startPressed(_ sender: Any) {
        startRide()
        startButton.isHidden = true
        pauseButton.isHidden = false
        stopButton.isHidden = false
        resumeButton.isHidden = true
    }
    
    @IBAction func stopPressed(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        stopTimer()
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        altitude = Measurement(value: 0, unit: UnitLength.meters)
        startButton.isHidden = false
        stopButton.isHidden = true
        pauseButton.isHidden = true
        resumeButton.isHidden = true
        updateDisplay()
    }
    
    @IBAction func pausePressed(_ sender: Any) {
        pauseTracking()
        pauseButton.isHidden = true
        resumeButton.isHidden = false
        startButton.isHidden = true
        stopButton.isHidden = false
        updateDisplay()
        
        
    }
    @IBAction func resumePressed(_ sender: Any) {
        resumeTracking()
        resumeButton.isHidden = true
        pauseButton.isHidden = false
        updateDisplay()
        wasPaused = true
    }
    
    func pauseTracking(){
        locationManager.stopUpdatingLocation()
        stopTimer()
        updateDisplay()
    }
    
    func resumeTracking(){
        locationManager.startUpdatingLocation()
        startTimer()
        updateDisplay()
    }
    func startRide() {
        
        //makes sure the location array is empty (deletes users previous ride)
        locationList.removeAll()
        //updates values on screen
        updateDisplay()
        //assigns the timner var a Timer with the refresh inverval of 1 second
        startTimer()
        startLocationUpdates()
        startButton.isHidden = true
        stopButton.isHidden = false
    }
    
    //after timer updates adds one second to seconds
    func eachSecond() {
        seconds += 1
        //used to update the screen with most current info
        updateDisplay()
    }
    func startTimer(){
        stopTimer()
        duration = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
    }
    func stopTimer() {
        duration?.invalidate()
    }
    
    private func updateDisplay() {
        let formattedDistance = Formatting.distance(distance)
        let formattedTime = Formatting.time(seconds)
        let formattedAltitude = Formatting.altitude(altitude)
        
        //changes distanceLabel to show current distance
        distanceLabel.text = formattedDistance
        altitudeLabel.text = formattedAltitude
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


//A lot of this is from stack overflow. I couldn't figure out how to code this myself. Of course I did modify a lot of the code to make it specific for my needs, such as all of the altitude stuff
extension DashboardViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if(wasPaused == false){
                if let lastLocation = locationList.last {
                    altitude = Measurement(value: lastLocation.altitude, unit: UnitLength.meters)
                    let delta = newLocation.distance(from: lastLocation)
                    distance = (distance + Measurement(value: delta, unit: UnitLength.meters))
                }
            }
            locationList.append(newLocation)
        }
        wasPaused = false
    }
}



