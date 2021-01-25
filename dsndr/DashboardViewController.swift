//
//  ViewController.swift
//  dsndr
//
//  Created by Brenton Babb on 12/18/20.
//

import UIKit
import Foundation
import CoreLocation

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
    private var isPaused = false
    
    private var currentAltitude = 0.0
    private var previousAltitude = 0.0
    private var currentDistance = 0.0
    private var previousDistance = 0.0
    private var isStopped = false
    private var isAscending = false
    private var pauseCheckerTimer: Timer?
    private var timeToCheck = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pauseCheckerTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) {_ in
            self.liftChecker()
        }
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
        
    }
    @IBAction func resumePressed(_ sender: Any) {
        resumeTracking()
    }
    
    func pauseTracking(){
        stopTimer()
        pauseButton.isHidden = true
        resumeButton.isHidden = false
        startButton.isHidden = true
        stopButton.isHidden = false
        isPaused = true
        updateDisplay()
    }
    
    func resumeTracking(){
        startTimer()
        resumeButton.isHidden = true
        pauseButton.isHidden = false
        isPaused = false
        wasPaused = true
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
        locationManager.activityType = .other
        //calls locationManger and starts to track location using apples CoreLocation library
        locationManager.startUpdatingLocation()
    }
    func liftChecker() {
        print("Current \(currentAltitude)")
        print("Previous \(previousAltitude)")

        if(currentAltitude >= previousAltitude && currentAltitude != 0 && previousAltitude != 0)
        {
            if isAscending == false{
                pauseTracking()
                isAscending = true
            }
            
        }
        
        else{
            if isAscending == true {
                resumeTracking()
                isAscending = false
            }
        }
        timeToCheck = true
    }
}




extension DashboardViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            print(Measurement(value: newLocation.altitude, unit: UnitLength.meters).value)

            if(wasPaused == false){
                if let lastLocation = locationList.last {
                    let delta = newLocation.distance(from: lastLocation)
                    
                    if isPaused == false{
                        previousDistance = distance.value
                        previousAltitude = altitude.value
                        distance = (distance + Measurement(value: delta, unit: UnitLength.meters))
                        altitude = Measurement(value: newLocation.altitude, unit: UnitLength.meters)
                        
                        currentDistance = distance.value
                        currentAltitude = altitude.value
                    }
                    else if timeToCheck == true{
                        previousDistance = currentAltitude
                        previousAltitude = currentAltitude
                        let nowDistance = (distance + Measurement(value: delta, unit: UnitLength.meters))
                        currentDistance = nowDistance.value
                        
                        let nowAltitude = Measurement(value: newLocation.altitude, unit: UnitLength.meters)
                        currentAltitude = nowAltitude.value
                        timeToCheck = false
                    }
                    else{
                    }
                    
                }
            }
            locationList.append(newLocation)
        }
        wasPaused = false
    }
}



