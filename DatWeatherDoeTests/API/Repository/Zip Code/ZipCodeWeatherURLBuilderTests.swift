//
//  ZipCodeWeatherURLBuilderTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 1/25/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import XCTest
@testable import DatWeatherDoe

class ZipCodeWeatherURLBuilderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBuild() {
        XCTAssertEqual(
            try? ZipCodeWeatherURLBuilder(appId: "123456", zipCode: "10021,us")
                .build().absoluteString,
            "https://api.openweathermap.org/data/2.5/weather?appid=123456&zip=10021,us"
        )
    }
}
