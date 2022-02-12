//
//  ConfigurationCommitterTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 2/12/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import XCTest
@testable import DatWeatherDoe

final class ConfigurationCommitterTests: XCTestCase {
    
    func testLocationSource() {
        let locationSource = WeatherSource.location
        
        XCTAssertEqual(locationSource.title, "Location")
        XCTAssertEqual(locationSource.menuIndex, 0)
        XCTAssertEqual(locationSource.placeholder, "")
        XCTAssertEqual(locationSource.textHint, "")
    }
    
    func testLatLongSource() {
        let latLongSource = WeatherSource.latLong
        
        XCTAssertEqual(latLongSource.title, "Lat/Long")
        XCTAssertEqual(latLongSource.menuIndex, 1)
        XCTAssertEqual(latLongSource.placeholder, "42,42")
        XCTAssertEqual(latLongSource.textHint, "[latitude],[longitude]")
    }
    
    func testZipCodeSource() {
        let zipCodeSource = WeatherSource.zipCode
        
        XCTAssertEqual(zipCodeSource.title, "Zip Code")
        XCTAssertEqual(zipCodeSource.menuIndex, 2)
        XCTAssertEqual(zipCodeSource.placeholder, "10021,us")
        XCTAssertEqual(zipCodeSource.textHint, "[zipcode],[iso 3166 country code]")
    }
}
