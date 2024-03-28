//
//  WeatherURLBuilderTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 1/25/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

@testable import DatWeatherDoe
import XCTest

final class WeatherURLBuilderTests: XCTestCase {
    func testBuild() {
        XCTAssertEqual(
            try? WeatherURLBuilder(appId: "123456").build().absoluteString,
            "https://api.openweathermap.org/data/2.5/weather"
        )
    }
}
