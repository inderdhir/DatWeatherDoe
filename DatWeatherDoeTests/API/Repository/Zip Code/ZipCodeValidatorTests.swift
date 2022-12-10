//
//  ZipCodeValidatorTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 1/26/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import XCTest
@testable import DatWeatherDoe

class ZipCodeValidatorTests: XCTestCase {
    
    func testValidate_zipCodeEmpty() {
        XCTAssertThrowsError(try ZipCodeValidator(zipCode: "").validate())
    }

    func testValidate_zipCodeIncorrect_wrongFormat() {
        XCTAssertThrowsError(try ZipCodeValidator(zipCode: "12345").validate())
    }
    
    func testValidate_zipCodeCorrect() {
        XCTAssertNoThrow(try ZipCodeValidator(zipCode: "10021,us").validate())
    }
}
