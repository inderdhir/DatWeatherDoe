//
//  DefaultsChecker.swift
//  SwiftWeather
//
//  Created by Inder Dhir on 1/29/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Foundation

final class DefaultsChecker {

    static let defaults = NSUserDefaults.standardUserDefaults()
    
    static let ZIP_CODE_CONFIG = "ZipCodeConfig"
    static let REFRESH_INTERVAL_CONFIG = "RefreshIntervalConfig"
    static let UNIT_CONFIG = "Unit"
    

    static func getDefaultZipCode() -> String {
        if let savedZipCode = defaults.stringForKey(ZIP_CODE_CONFIG) {
            return savedZipCode
        }
        else {
            return "10021,us"
        }
    }
    
    static func getDefaultRefreshInterval() -> NSTimeInterval {
        if let savedRefreshInterval = defaults.stringForKey(REFRESH_INTERVAL_CONFIG) {
            return NSTimeInterval(savedRefreshInterval)!
        }
        else {
            return 60
        }
    }
    
    static func getDefaultUnit() -> String {
        if let savedUnit = defaults.stringForKey(UNIT_CONFIG) {
            return savedUnit
        }
        else {
            return TemperatureUnits.F_UNIT.rawValue
        }
    }
    
    static func setDefaultZipCode(zipCode: String) {
        defaults.setObject(zipCode, forKey: ZIP_CODE_CONFIG)
    }
    
    static func setDefaultRefreshInterval(refreshInterval: String) {
        defaults.setObject(refreshInterval, forKey: REFRESH_INTERVAL_CONFIG)
    }
    
    static func setDefaultUnit(unit: String) {
        defaults.setObject(unit, forKey: UNIT_CONFIG)
    }
}