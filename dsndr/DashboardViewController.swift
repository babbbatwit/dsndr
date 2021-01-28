//
//  DashboardViewController.swift
//  dsndr
//
//  Created by Brenton Babb on 12/18/20.
//

import UIKit
import Foundation
import CoreLocation

class DashboardViewController: UIViewController {
    //ui variables
    @IBOutlet var altitudeLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var resumeButton: UIButton!
    @IBOutlet var lapsLabel: UILabel!
    
    //location variables and variables that will be displayed
    private let locationManager = LocationManager.shared
    private var seconds = 0
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var altitude = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
    private var laps = 0

    //behind the scences doubles
    private var currentAltitude = 0.0
    private var previousAltitude = 0.0
    private var currentDistance = 0.0
    private var previousDistance = 0.0
    
    //timers used for checking various things
    private var hasUpdatedTimer: Timer?
    private var pauseCheckerTimer: Timer?
    private var rideStartTimer: Timer?
    private var duration: Timer?
    private var resumeTimer: Timer?
    //booleans and their default states on launch
    private var wasJustStaretd = true
    private var hasUpdated = false
    private var isStopped = false
    private var isAscending = false
    private var timeToCheck = false
    private var wasPaused = false
    private var isPaused = false
    private var userPaused = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //default states of ui elements
        stopButton.isHidden = true
        pauseButton.isHidden = true
        resumeButton.isHidden = true
        hasUpdated = true
    }
    
    //fucntion used when the start button is pressed. Hides and reveals specific buttons
    @IBAction func startPressed(_ sender: Any) {
        startRide()
        startButton.isHidden = true
        pauseButton.isHidden = false
        stopButton.isHidden = false
        resumeButton.isHidden = true
    }
    //fucntion used when the stop button is pressed. Hides and reveals specific buttons and ensures that all variables return to their default state
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
        pauseCheckerTimer?.invalidate()
        hasUpdatedTimer?.invalidate()
        rideStartTimer?.invalidate()
        duration?.invalidate()
        resumeTimer?.invalidate()
        hasUpdated = false
        isStopped = false
        isAscending = false
        timeToCheck = false
        wasPaused = false
        isPaused = false
        userPaused = false
        updateDisplay()
    }
    //fucntion used when the pause button is pressed. Hides and reveals specific buttons
    @IBAction func pausePressed(_ sender: Any) {
        pauseTracking()
        userPaused = true
    }
    //fucntion used when the resume button is pressed. Hides and reveals specific buttons
    @IBAction func resumePressed(_ sender: Any) {
        resumeTracking()
        userPaused = false
    }
    //Fucntion used when app needs to pause tracking. Specifically does not stop location services, but stops timer. Turns on variables that are then used later to pause to collection of total distance
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
    //Resumes tracking the users distance and adding that to the total amount of distance. Turns need booleans to on or off depending on what they are asking
    func resumeTracking(){
        startTimer()
        resumeButton.isHidden = true
        pauseButton.isHidden = false
        startResumeTimer()
        isPaused = false
        wasPaused = true
        isStopped = false
        updateDisplay()
    }
    //This makes sure to wipe any current data. Starts a one time timer that acts as a buffer so the app doesn't automatically pause tracking when the app has just started
    func startRide() {
        //starts a repeating timer that calls liftChecker() and movingChecker()
        pauseCheckerTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) {_ in
            self.liftChecker()
            self.movingChecker()
            self.timeToCheck = true
        }
        wasJustStaretd = true
        locationList.removeAll()
        updateDisplay()
        startTimer()
        startLocationUpdates()
        startResumeTimer()
        startButton.isHidden = true
        stopButton.isHidden = false
    }
    //The duration timer calls this every second. Just adds one to seconds which is then displayed in the format of 00:00:00 to the user
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    //This starts the timer that tracks total duration. Every 1 seconds the timer updates which calls the eachSecond() function which adds 1 to the seconds variable
    func startTimer(){
        stopTimer()
        duration = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
    }
    //invailidates the duration timer. It stops it from ticking, but does not wipe the seconds variable
    func stopTimer() {
        duration?.invalidate()
    }
    //when ever something changes in the app this function is called. It is specifcally for displaying the useful collected information to the user. Calls over to the Formatting.swift file to format the text properly for viewing
    private func updateDisplay() {
        let formattedDistance = Formatting.distance(distance)
        let formattedTime = Formatting.time(seconds)
        let formattedAltitude = Formatting.altitude(altitude)
        
        distanceLabel.text = ("Distance: \(formattedDistance)")
        altitudeLabel.text = ("Altitude: \(formattedAltitude)")
        timeLabel.text = formattedTime
        lapsLabel.text = "Laps: \(laps)"
    }
    //Sets locactionMangagers prefrences. This provides accuracy for the app. Specifically for bug testing right now
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    //liftChecker is the function that checks if the user is gaining alitude instead of losing altitude. If the user is ascending then it calls pauseTracking(), sets laps to +1, and turns specfific variables to what they need to be
    func liftChecker() {
        if previousAltitude - currentAltitude > 5 && currentAltitude != 0 && previousAltitude != 0 && wasJustStaretd == false  {
            //this checks if isAscending hasn't been turned to false yet and if it hasn't do what it needs to do
            if isAscending == false{
                pauseTracking()
                isAscending = true
                laps += 1
            }
            
        }
        //if the first if statement false that means they aren't acending so it comes to here. It then hits the imbeded if statement to see if isAscending is equal to true, and if so turn it to false because they are no longer ascending
        else{
            if isAscending == true {
                resumeTracking()
                isAscending = false
            }
        }
    }
    //checks if the locationManager() function has turned hasUpdated to false, which means the user hasn't moved with in a 10 second period. Pauses tracking.
    func movingChecker() {
        if hasUpdated == false && wasJustStaretd == false {
            if isStopped == false{
                pauseTracking()
                
            }
        }
        else{
            //If the first if statement fails it means they are moving. If the user manual paused the app it won't auto kick in. This is a key element of use cases. You wouldn't want the app overiding your personal pause
            if isStopped == true && userPaused == false {
                resumeTracking()
                
            }
        }
    }
    
    func startResumeTimer(){
        wasJustStaretd = true
        rideStartTimer?.invalidate()
        rideStartTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) {_ in
            self.wasJustStaretd = false
        }
    }
    
}

//extension of DashboardViewController that deals with all the location updating
extension DashboardViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //invalitdates the timmer that is started at the bottom of this function
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            hasUpdated = true
            hasUpdatedTimer?.invalidate()
            //Prevents tracking a paused distance compared to currently location. Would cause inaccuracy
            if(wasPaused == false){
                if let lastLocation = locationList.last {
                    let delta = newLocation.distance(from: lastLocation)
                    
                    if isPaused == false{
                        distance = (distance + Measurement(value: delta, unit: UnitLength.meters))
                        altitude = Measurement(value: newLocation.altitude, unit: UnitLength.meters)
                    }
                    //if statement to see if timeToCheck, which is true every 10 seconds, is true. If so it updates the behind the scenes distance and altitude
                    if timeToCheck == true{
                        previousDistance = currentDistance
                        previousAltitude = currentAltitude
                        
                        let nowDistance = (Measurement(value: currentDistance, unit: UnitLength.meters) + Measurement(value: delta, unit: UnitLength.meters))
                        currentDistance = nowDistance.value
                        
                        let nowAltitude = Measurement(value: newLocation.altitude, unit: UnitLength.meters)
                        currentAltitude = nowAltitude.value
                        
                        timeToCheck = false
                    }
                }
            }
            locationList.append(newLocation)
        }
        //sets wasPaused to false, because it would have made one full run after a pause. Prevents tracking an unwanted distance. Also the timer goes off after 10 seconds and if the timer actually goes off it means this function hasn't happened within 10 seconds because at the top of this function the timer is invailidated
        wasPaused = false
        hasUpdatedTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false){_ in
            self.hasUpdated = false
        }
    }
}



