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
    @IBOutlet var lapsLabel: UILabel!
    
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var duration: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var altitude = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    private var laps = 0
    private var wasPaused = false
    private var isPaused = false
    private var rideStartTimer: Timer?
    private var wasJustStaretd = true
    private var userPaused = false
    
    private var currentAltitude = 0.0
    private var previousAltitude = 0.0
    private var currentDistance = 0.0
    private var previousDistance = 0.0
    private var isStopped = false
    private var isAscending = false
    private var pauseCheckerTimer: Timer?
    private var timeToCheck = false
    private var hasUpdatedTimer: Timer?
    private var hasUpdated = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pauseCheckerTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) {_ in
            self.liftChecker()
            self.movingChecker()
            self.timeToCheck = true
            
        }
        stopButton.isHidden = true
        pauseButton.isHidden = true
        resumeButton.isHidden = true
        hasUpdated = true
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
        laps = 0
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
        userPaused = true
    }
    @IBAction func resumePressed(_ sender: Any) {
        resumeTracking()
        userPaused = false
    }
    
    func pauseTracking(){
        stopTimer()
        pauseButton.isHidden = true
        resumeButton.isHidden = false
        startButton.isHidden = true
        stopButton.isHidden = false
        isStopped = true
        isPaused = true
        updateDisplay()
    }
    
    func resumeTracking(){
        startTimer()
        resumeButton.isHidden = true
        pauseButton.isHidden = false
        isPaused = false
        wasPaused = true
        isStopped = false
        updateDisplay()
    }
    func startRide() {
        wasJustStaretd = true
        locationList.removeAll()
        updateDisplay()
        startTimer()
        startLocationUpdates()
        rideStartTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false) {_ in
            self.wasJustStaretd = false
        }
        startButton.isHidden = true
        stopButton.isHidden = false
    }
    
    func eachSecond() {
        seconds += 1
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
        
        distanceLabel.text = ("Distance: \(formattedDistance)")
        altitudeLabel.text = ("Altitude: \(formattedAltitude)")
        timeLabel.text = formattedTime
        lapsLabel.text = "Laps: \(laps)"
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 3
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    func liftChecker() {
        print("Current alt \(currentAltitude)")
        print("Previous alt \(previousAltitude)")

        if currentAltitude >= previousAltitude && currentAltitude != 0 && previousAltitude != 0 && wasJustStaretd == false  {
            if isAscending == false{
                pauseTracking()
                isAscending = true
            }
            
        }
        
        else{
            if isAscending == true {
                resumeTracking()
                laps += 1
                isAscending = false
            }
        }
    }
    
    func movingChecker() {
        print("Current distance \(currentDistance)")
        print("Previous distance \(previousDistance)")
        if hasUpdated == false && wasJustStaretd == false {
            if isStopped == false{
                pauseTracking()

            }
        }
        else{
            if isStopped == true && userPaused == false {
                resumeTracking()

            }
        }
    }
    
}




extension DashboardViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(0)
        hasUpdated = true
        hasUpdatedTimer?.invalidate()
        for newLocation in locations {
            //let howRecent = newLocation.timestamp.timeIntervalSinceNow
            //guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            print(Measurement(value: newLocation.altitude, unit: UnitLength.meters).value)

            if(wasPaused == false){
                print(1)
                if let lastLocation = locationList.last {
                    let delta = newLocation.distance(from: lastLocation)
                    
                    if isPaused == false{
                        previousDistance = currentDistance
                        previousAltitude = currentAltitude
                        distance = (distance + Measurement(value: delta, unit: UnitLength.meters))
                        altitude = Measurement(value: newLocation.altitude, unit: UnitLength.meters)
                        
                        currentDistance = distance.value
                        currentAltitude = altitude.value
                    }
                    if timeToCheck == true{
                        print("yayayayayaya")
                        previousDistance = currentDistance
                        previousAltitude = currentAltitude
                        
                        let nowDistance = (Measurement(value: currentDistance, unit: UnitLength.meters) + Measurement(value: delta, unit: UnitLength.meters))
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
        hasUpdatedTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false){_ in
            self.hasUpdated = false
        }
    }
}



