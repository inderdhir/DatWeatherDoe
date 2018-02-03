//
//  DefaultsChecker.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/29/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Foundation

final class DefaultsChecker {

    static let defaults = UserDefaults.standard
    static let zipCodeConfig = "ZipCodeConfig"
    static let refreshIntervalConfig = "RefreshIntervalConfig"
    static let unitConfig = "UnitConfig"
    static let locationConfig = "LocationConfig"

    static func getDefaultZipCode() -> String {
        if defaults.object(forKey: zipCodeConfig) == nil {
            return "10021,us"
        }
        
        if let savedZipCode = defaults.string(forKey: zipCodeConfig) {
            return savedZipCode
        }
        return "10021,us"
    }
    
    static func getDefaultRefreshInterval() -> TimeInterval {
        if let savedRefreshInterval = defaults.string(forKey: refreshIntervalConfig) {
            return TimeInterval(savedRefreshInterval)!
        }
        return 60
    }

    static func getDefaultUnit() -> String {
        if let savedUnit = defaults.string(forKey: unitConfig) {
            if savedUnit == TemperatureUnit.fahrenheit.rawValue ||
                savedUnit == TemperatureUnit.celsius.rawValue {
                return savedUnit
            } else {
                return TemperatureUnit.fahrenheit.rawValue
            }
        }
        return TemperatureUnit.fahrenheit.rawValue
    }

    static func getDefaultLocationUsedToggle() -> Bool {
        // Needed since non-existant key returns false
        if defaults.object(forKey: locationConfig) == nil {
            return true
        }
        return defaults.bool(forKey: locationConfig)
    }
    
    static func setDefaultZipCode(_ zipCode: String) {
        defaults.set(zipCode, forKey: zipCodeConfig)
    }
    
    static func setDefaultRefreshInterval(_ refreshInterval: String) {
        defaults.set(refreshInterval, forKey: refreshIntervalConfig)
    }
    
    static func setDefaultUnit(_ unit: String) {
        defaults.set(unit, forKey: unitConfig)
    }
    
    static func setDefaultLocationUsedToggle(_ isUsed: Bool) {
        defaults.set(isUsed, forKey: locationConfig)
    }
}
