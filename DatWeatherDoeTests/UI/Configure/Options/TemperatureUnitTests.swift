//
//  TemperatureUnitTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 2/12/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

@testable import DatWeatherDoe
import XCTest

final class TemperatureUnitTests: XCTestCase {
    func testFahrenheit() {
        let fahrenheitUnit = TemperatureUnit.fahrenheit

        XCTAssertEqual(fahrenheitUnit.unitString, "F")
        XCTAssertEqual(fahrenheitUnit.degreesString, "\u{00B0}F")
    }

    func testCelsius() {
        let fahrenheitUnit = TemperatureUnit.celsius

        XCTAssertEqual(fahrenheitUnit.unitString, "C")
        XCTAssertEqual(fahrenheitUnit.degreesString, "\u{00B0}C")
    }

    func testAll() {
        let fahrenheitUnit = TemperatureUnit.all

        XCTAssertEqual(fahrenheitUnit.unitString, "All")
        XCTAssertEqual(fahrenheitUnit.degreesString, "\u{00B0}All")
    }
}
