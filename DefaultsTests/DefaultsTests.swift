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
        XCTAssertEqual(DefaultsManager.shared.zipCode, "10021,us")
    }
    
    func testZipCodeSaved() {
        XCTAssertEqual(DefaultsManager.shared.zipCode, "10021,us")
        DefaultsManager.shared.zipCode = "30907,us"
        XCTAssertEqual(DefaultsManager.shared.zipCode, "30907,us")
    }
    
    func testDefaultTemperatureUnit() {
        XCTAssertEqual(DefaultsManager.shared.unit, TemperatureUnit.fahrenheit)
    }
    
    func testTemperatureUnitSaved() {
        XCTAssertEqual(DefaultsManager.shared.unit, TemperatureUnit.fahrenheit)
        DefaultsManager.shared.unit = .celsius
        XCTAssertEqual(DefaultsManager.shared.unit, TemperatureUnit.celsius)
    }
    
    func testDefaultLocationUsedToggle() {
        XCTAssertEqual(DefaultsManager.shared.usingLocation, false)
    }
    
    func testLocationUsedToggleSaved() {
        XCTAssertEqual(DefaultsManager.shared.usingLocation, false)
        DefaultsManager.shared.usingLocation = true
        XCTAssertEqual(DefaultsManager.shared.usingLocation, true)
    }
    
    func testDefaultRefreshInterval() {
        XCTAssertEqual(DefaultsManager.shared.refreshInterval, 60)
    }
    
    func testRefreshIntervalSaved() {
        XCTAssertEqual(DefaultsManager.shared.refreshInterval, 60)
        DefaultsManager.shared.refreshInterval = 300
        XCTAssertEqual(DefaultsManager.shared.refreshInterval, 300)
    }

    private func clearUserDefaults() {
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.resetStandardUserDefaults()
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
    }
}
