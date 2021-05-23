//
//  ConfigManagerTests.swift
//  DefaultsTests
//
//  Created by Inder Dhir on 5/23/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import XCTest
@testable import DatWeatherDoe

class ConfigManagerTests: XCTestCase {

    var configManager: ConfigManagerType!

    override func setUp() {
        super.setUp()
        clearUserDefaults()
    }

    override func tearDown() {
        clearUserDefaults()
        super.tearDown()
    }

    func testDefaultTemperatureUnit() {
        XCTAssertEqual(configManager.temperatureUnit, TemperatureUnit.fahrenheit.rawValue)
    }

    func testTemperatureUnitSaved() {
        XCTAssertEqual(configManager.temperatureUnit, TemperatureUnit.fahrenheit.rawValue)
        configManager.temperatureUnit = TemperatureUnit.celsius.rawValue
        XCTAssertEqual(configManager.temperatureUnit, TemperatureUnit.celsius.rawValue)
    }

    func testDefaultLocationToggle() {
        XCTAssertEqual(configManager.isUsingLocation, false)
    }

    func testLocationToggleSaved() {
        XCTAssertEqual(configManager.isUsingLocation, false)
        configManager.isUsingLocation = true
        XCTAssertEqual(configManager.isUsingLocation, true)
    }

    func testDefaultZipCode() {
        XCTAssertEqual(configManager.zipCode, nil)
    }

    func testZipCodeSaved() {
        XCTAssertEqual(configManager.zipCode, nil)
        configManager.zipCode = "10021,us"
        XCTAssertEqual(configManager.zipCode, "10021,us")
    }

    func testDefaultLatLong() {
        XCTAssertEqual(configManager.latLong, nil)
    }

    func testLatLongSaved() {
        XCTAssertEqual(configManager.latLong, nil)
        configManager.latLong = "20,20"
        XCTAssertEqual(configManager.latLong, "20,20")
    }

    func testDefaultRefreshInterval() {
        XCTAssertEqual(configManager.refreshInterval, 900)
    }

    func testRefreshIntervalSaved() {
        XCTAssertEqual(configManager.refreshInterval, 900)
        configManager.refreshInterval = 300
        XCTAssertEqual(configManager.refreshInterval, 300)
    }

    func testDefaultShowingHumidity() {
        XCTAssertEqual(configManager.isShowingHumidity, false)
    }

    func testShowingHumiditySaved() {
        XCTAssertEqual(configManager.isShowingHumidity, false)
        configManager.isShowingHumidity = true
        XCTAssertEqual(configManager.isShowingHumidity, true)
    }

    func testDefaultRoundingOffData() {
        XCTAssertEqual(configManager.isRoundingOffData, false)
    }

    func testRoundingOffDataSaved() {
        XCTAssertEqual(configManager.isRoundingOffData, false)
        configManager.isRoundingOffData = true
        XCTAssertEqual(configManager.isRoundingOffData, true)
    }

    private func clearUserDefaults() {
        let appDomain = Bundle.main.bundleIdentifier ?? "DatWeatherDoe"
        UserDefaults.resetStandardUserDefaults()
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        configManager = ConfigManager()
    }
}
