//
//  CityWeatherURLBuilderTests.swift
//  DatWeatherDoeTests
//
//  Created by preckrasno on 14.02.2023.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

@testable import DatWeatherDoe
import XCTest

class CityWeatherURLBuilderTests: XCTestCase {
    func testBuild() {
        XCTAssertEqual(
            try? CityWeatherURLBuilder(appId: "123456", city: "Kyiv,ua")
                .build(unit: .metric).absoluteString,
            "https://api.openweathermap.org/data/2.5/weather?appid=123456&q=Kyiv,ua&units=metric"
        )
    }
}
