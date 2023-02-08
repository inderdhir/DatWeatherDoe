//
//  LocationWeatherURLBuilderTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 1/25/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import XCTest
@testable import DatWeatherDoe

class LocationWeatherURLBuilderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testBuild() {
        XCTAssertEqual(
            try? LocationWeatherURLBuilder(
                appId: "123456",
                location: .init(latitude: 42, longitude: 42)
            ).build(unit: .imperial).absoluteString,
            "https://api.openweathermap.org/data/2.5/weather?appid=123456&lat=42.0&lon=42.0"
        )
    }
}
