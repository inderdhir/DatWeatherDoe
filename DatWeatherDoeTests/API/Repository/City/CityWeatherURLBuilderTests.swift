//
//  CityWeatherURLBuilderTests.swift
//  DatWeatherDoeTests
//
//  Created by preckrasno on 14.02.2023.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import XCTest
@testable import DatWeatherDoe

class CityWeatherURLBuilderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBuild() {
        XCTAssertEqual(
            try? CityWeatherURLBuilder(appId: "123456", city: "Kyiv,ua")
                .build().absoluteString,
            "https://api.openweathermap.org/data/2.5/weather?appid=123456&q=Kyiv,ua"
        )
    }
}
