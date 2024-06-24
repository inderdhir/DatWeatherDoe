//
//  ConfigManagerTests.swift
//  DefaultsTests
//
//  Created by Inder Dhir on 5/23/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

@testable import DatWeatherDoe
import XCTest

final class ConfigManagerTests: XCTestCase {
    var configManager: ConfigManagerType!

    override func setUp() {
        super.setUp()
        clearUserDefaults()
    }

    func testDefaultMeasurementUnit() {
        XCTAssertEqual(configManager.measurementUnit, MeasurementUnit.imperial.rawValue)
    }

    func testMeasurementUnitSaved() {
        XCTAssertEqual(configManager.measurementUnit, MeasurementUnit.imperial.rawValue)
        configManager.measurementUnit = MeasurementUnit.metric.rawValue
        XCTAssertEqual(configManager.measurementUnit, MeasurementUnit.metric.rawValue)
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
        configManager.weatherSourceText = "40,40"
        XCTAssertEqual(configManager.weatherSourceText, "40,40")
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

    func testDefaultUnitLetterOffOffData() {
        XCTAssertEqual(configManager.isUnitLetterOff, false)
    }

    func testDefaultisUnitSymbolOff() {
        XCTAssertEqual(configManager.isUnitSymbolOff, false)
    }

    func testRoundingOffDataSaved() {
        XCTAssertEqual(configManager.isRoundingOffData, false)
        configManager.isRoundingOffData = true
        XCTAssertEqual(configManager.isRoundingOffData, true)
    }

    func testUnitLetterOffSaved() {
        XCTAssertEqual(configManager.isUnitLetterOff, false)
        configManager.isUnitLetterOff = true
        XCTAssertEqual(configManager.isUnitLetterOff, true)
    }

    func testUnitSymbolOffSaved() {
        XCTAssertEqual(configManager.isUnitSymbolOff, false)
        configManager.isUnitSymbolOff = true
        XCTAssertEqual(configManager.isUnitSymbolOff, true)
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
