//
//  LocationValidatorTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 1/26/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import XCTest
@testable import DatWeatherDoe

class LocationValidatorTests: XCTestCase {

    func testLocation_empty() {
        XCTAssertThrowsError(try LocationValidator(latLong: "").validate())
    }
    
    func testLocation_correct() {
        XCTAssertNoThrow(try LocationValidator(latLong: "12,24").validate())
    }
}
