//
//  Formatting.swift
//  dsndr
//
//  Created by Brenton Babb on 1/24/21.
//


import Foundation


struct Formatting {
    
    static func distance(_ distance: Double) -> String {
        let distanceMeasurement = Measurement(value: distance, unit: UnitLength.meters)
        return Formatting.distance(distanceMeasurement)
    }
    
    static func distance(_ distance: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 2
        return formatter.string(from: distance)
    }
    static func time(_ seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(seconds))!
    }
    
    static func altitude(_ altitude: Double) -> String {
        let altitudeMeasurement = Measurement(value: altitude, unit: UnitLength.feet)
        return Formatting.altitude(altitudeMeasurement)
    }
    
    static func altitude(_ altitude: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.unitOptions = .naturalScale
        return formatter.string(from: altitude)
    }
}
