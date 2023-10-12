//
//  LocationValidatorTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 1/26/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

@testable import DatWeatherDoe
import XCTest

class LocationValidatorTests: XCTestCase {
    func testLocation_empty() {
        XCTAssertThrowsError(try LocationValidator(latLong: "").validate())
    }

    func testLocation_correct() {
        XCTAssertNoThrow(try LocationValidator(latLong: "12,24").validate())
    }
}
