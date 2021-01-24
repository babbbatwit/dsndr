//
//  Formatting.swift
//  dsndr
//
//  Created by Brenton Babb on 1/24/21.
//


import Foundation

//THE PERSON WHO MADE ALL THE FORMATTER STUFF, LIKE DateComponentsFormatter(), HONESTLY NEEDS A RAISE. THIS STUFF IS SO HELPFUL

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
    
}
