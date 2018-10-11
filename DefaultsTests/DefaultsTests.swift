//
//  DefaultsTests.swift
//  DefaultsTests
//
//  Created by Inder Dhir on 2/22/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import XCTest
@testable import DatWeatherDoe

class DefaultsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        clearUserDefaults()
    }
    
    override func tearDown() {
        clearUserDefaults()
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

    private func clearUserDefaults() {
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.resetStandardUserDefaults()
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
    }
}
