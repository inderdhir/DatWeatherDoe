//
//  DefaultsTests.swift
//  DefaultsTests
//
//  Created by Inder Dhir on 2/22/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import XCTest
@testable import SwiftWeather

class DefaultsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Clear defaults for each test
//        var defaults = NSUserDefaults.standardUserDefaults().dictionaryRepresentation()
//        for item in defaults {
//            let key = item.0
//            if key == DefaultsChecker.ZIP_CODE_CONFIG || key == DefaultsChecker.REFRESH_INTERVAL_CONFIG || key == DefaultsChecker.UNIT_CONFIG || key == DefaultsChecker.LOCATION_CONFIG {
//                defaults.removeValueForKey(key)
//            }
//        }
//        NSUserDefaults.standardUserDefaults().synchronize()

        let appDomain = NSBundle.mainBundle().bundleIdentifier!
        NSUserDefaults.resetStandardUserDefaults()
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDefaultZipCode() {
        let zipCode = DefaultsChecker.getDefaultZipCode()
        XCTAssertEqual(zipCode, "10021,us")
    }
    
    func testZipCodeSaved() {
        var zipCode = DefaultsChecker.getDefaultZipCode()
        XCTAssertEqual(zipCode, "10021,us")
        
        zipCode = TemperatureUnits.C_UNIT.rawValue
        DefaultsChecker.setDefaultZipCode(zipCode)
        XCTAssertEqual(zipCode, DefaultsChecker.getDefaultZipCode())
    }
    
    func testDefaultTemperatureUnit() {
        let tempUnit = DefaultsChecker.getDefaultUnit()
        XCTAssertEqual(tempUnit, TemperatureUnits.F_UNIT.rawValue)
    }
    
    func testTemperatureUnitSaved() {
        var tempUnit = DefaultsChecker.getDefaultUnit()
        XCTAssertEqual(tempUnit, TemperatureUnits.F_UNIT.rawValue)
        
        tempUnit = TemperatureUnits.C_UNIT.rawValue
        DefaultsChecker.setDefaultUnit(tempUnit)
        XCTAssertEqual(tempUnit, DefaultsChecker.getDefaultUnit())
    }
    
    func testDefaultLocationUsedToggle() {
        let locationToggle = DefaultsChecker.getDefaultLocationUsedToggle()
        print(locationToggle)
        XCTAssertTrue(locationToggle)
    }
    
    func testLocationUsedToggleSaved() {
        var locationToggle = DefaultsChecker.getDefaultLocationUsedToggle()
        XCTAssertTrue(locationToggle)
        
        locationToggle = false
        DefaultsChecker.setDefaultLocationUsedToggle(locationToggle)
        XCTAssertFalse(DefaultsChecker.getDefaultLocationUsedToggle())
    }
    
    func testDefaultRefreshInterval() {
        let refreshInterval = DefaultsChecker.getDefaultRefreshInterval()
        XCTAssertEqual(refreshInterval, 60)
    }
    
    func testRefreshIntervalSaved() {
        var refreshInterval = DefaultsChecker.getDefaultRefreshInterval()
        XCTAssertEqual(refreshInterval, 60)
        
        refreshInterval = 300
        DefaultsChecker.setDefaultRefreshInterval(String(refreshInterval))
        XCTAssertEqual(refreshInterval, DefaultsChecker.getDefaultRefreshInterval())
    }
}
