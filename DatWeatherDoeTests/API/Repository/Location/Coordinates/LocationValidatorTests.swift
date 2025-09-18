//
//  LocationValidatorTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 1/26/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

@testable import DatWeatherDoe
import Testing

struct LocationValidatorTests {
    
    @Test
    func testLocation_empty() async throws {
        #expect(throws: (any Error).self) {
            try LocationValidator(latLong: "").validate()
        }
    }

    @Test
    func testLocation_correct() async throws {
        #expect(throws: Never.self) {
            try LocationValidator(latLong: "12,24").validate()
        }
    }
}
