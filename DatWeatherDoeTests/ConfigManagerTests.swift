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

    func testDefaultWeatherSource() {
        XCTAssertEqual(configManager.weatherSource, WeatherSource.location.rawValue)
    }

    func testDefaultWeatherSourceSaved() {
        XCTAssertEqual(configManager.weatherSource, WeatherSource.location.rawValue)
        configManager.weatherSource = WeatherSource.latLong.rawValue
        XCTAssertEqual(configManager.weatherSource, WeatherSource.latLong.rawValue)
    }

    func testDefaultWeatherSourceText() {
        XCTAssertEqual(configManager.weatherSourceText, nil)
    }

    func testWeatherSourceTextSaved() {
        XCTAssertEqual(configManager.weatherSourceText, nil)
        configManager.weatherSourceText = "10021,us"
        XCTAssertEqual(configManager.weatherSourceText, "10021,us")
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

    func testWeatherConditionAsTextDefault() {
        XCTAssertEqual(configManager.isWeatherConditionAsTextEnabled, false)
    }

    func testWeatherConditionAsTextSaved() {
        XCTAssertEqual(configManager.isWeatherConditionAsTextEnabled, false)
        configManager.isWeatherConditionAsTextEnabled = true
        XCTAssertEqual(configManager.isWeatherConditionAsTextEnabled, true)
    }

    private func clearUserDefaults() {
        let appDomain = Bundle.main.bundleIdentifier ?? "DatWeatherDoe"
        UserDefaults.resetStandardUserDefaults()
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
        configManager = ConfigManager()
    }
}
