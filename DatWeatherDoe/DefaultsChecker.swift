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
    
    static let ZIP_CODE_CONFIG = "ZipCodeConfig"
    static let REFRESH_INTERVAL_CONFIG = "RefreshIntervalConfig"
    static let UNIT_CONFIG = "UnitConfig"
    static let LOCATION_CONFIG = "LocationConfig"
    

    static func getDefaultZipCode() -> String {
        if defaults.object(forKey: ZIP_CODE_CONFIG) == nil {
            return "10021,us"
        }
        
        if let savedZipCode = defaults.string(forKey: ZIP_CODE_CONFIG) {
            return savedZipCode
        }
        else {
            return "10021,us"
        }
    }
    
    static func getDefaultRefreshInterval() -> TimeInterval {
        if let savedRefreshInterval = defaults.string(forKey: REFRESH_INTERVAL_CONFIG) {
            return TimeInterval(savedRefreshInterval)!
        }
        else {
            return 60
        }
    }
    
    static func getDefaultUnit() -> String {
        if let savedUnit = defaults.string(forKey: UNIT_CONFIG) {
            if savedUnit == TemperatureUnits.F_UNIT.rawValue || savedUnit == TemperatureUnits.C_UNIT.rawValue {
                return savedUnit
            }
            else {
                return TemperatureUnits.F_UNIT.rawValue
            }
        }
        else {
            return TemperatureUnits.F_UNIT.rawValue
        }
    }
    
    static func getDefaultLocationUsedToggle() -> Bool {
        // Needed since non-existant key returns false
        if defaults.object(forKey: LOCATION_CONFIG) == nil {
            return true
        }
        return defaults.bool(forKey: LOCATION_CONFIG)
    }
    
    static func setDefaultZipCode(_ zipCode: String) {
        defaults.set(zipCode, forKey: ZIP_CODE_CONFIG)
    }
    
    static func setDefaultRefreshInterval(_ refreshInterval: String) {
        defaults.set(refreshInterval, forKey: REFRESH_INTERVAL_CONFIG)
    }
    
    static func setDefaultUnit(_ unit: String) {
        defaults.set(unit, forKey: UNIT_CONFIG)
    }
    
    static func setDefaultLocationUsedToggle(_ isUsed: Bool) {
        defaults.set(isUsed, forKey: LOCATION_CONFIG)
    }
}
