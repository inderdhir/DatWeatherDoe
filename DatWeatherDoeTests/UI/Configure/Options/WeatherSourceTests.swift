//
//  WeatherSourceTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 2/12/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

@testable import DatWeatherDoe
import XCTest

final class WeatherSourceTests: XCTestCase {
    func testLocationSource() {
        let locationSource = WeatherSource.location

        XCTAssertEqual(locationSource.title, "Location")
        XCTAssertEqual(locationSource.placeholder, "")
        XCTAssertEqual(locationSource.textHint, "")
    }

    func testLatLongSource() {
        let latLongSource = WeatherSource.latLong

        XCTAssertEqual(latLongSource.title, "Lat/Long")
        XCTAssertEqual(latLongSource.placeholder, "42,42")
        XCTAssertEqual(latLongSource.textHint, "[latitude],[longitude]")
    }
}
