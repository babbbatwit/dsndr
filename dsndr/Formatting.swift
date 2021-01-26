//
//  Formatting.swift
//  dsndr
//
//  Created by Brenton Babb on 1/24/21.
//

//this file is for the converting functions. It takes in measurements and converts them into nice, readable strings.
import Foundation


struct Formatting {
    //converts a double into a readable distance
    static func distance(_ distance: Double) -> String {
        let distanceMeasurement = Measurement(value: distance, unit: UnitLength.meters)
        return Formatting.distance(distanceMeasurement)
    }
    //little recursion going on up in here. This second one is called after the first one
    static func distance(_ distance: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        //who ever called the function to set a desired amount of decimals to maximumFractionDigits should be fired
        formatter.numberFormatter.maximumFractionDigits = 2
        return formatter.string(from: distance)
    }
    //uses the handy DateComponentsFormatter() to make seconds into a readable time
    static func time(_ seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(seconds))!
    }
    //basically the same thing thing as the distance one, but just for altitude
    static func altitude(_ altitude: Double) -> String {
        let altitudeMeasurement = Measurement(value: altitude, unit: UnitLength.meters)
        return Formatting.altitude(altitudeMeasurement)
    }
    
    static func altitude(_ altitude: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.unitOptions = .naturalScale
        return formatter.string(from: altitude)
    }
}
