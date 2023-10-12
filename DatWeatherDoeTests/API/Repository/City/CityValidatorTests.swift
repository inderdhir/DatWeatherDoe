//
//  CityValidatorTests.swift
//  DatWeatherDoeTests
//
//  Created by preckrasno on 14.02.2023.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

@testable import DatWeatherDoe
import XCTest

class CityValidatorTests: XCTestCase {
    func testValidate_cityEmpty() {
        XCTAssertThrowsError(try CityValidator(city: "").validate())
    }

    func testValidate_cityIncorrect_wrongFormat() {
        XCTAssertThrowsError(try CityValidator(city: "12345").validate())
    }

    func testValidate_cityCorrect() {
        XCTAssertNoThrow(try CityValidator(city: "Kyiv,ua").validate())
    }
}
