//
//  RefreshIntervalTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 2/12/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

@testable import DatWeatherDoe
import XCTest

final class RefreshIntervalTests: XCTestCase {
    func testRefreshIntervalTimes() {
        XCTAssertEqual(RefreshInterval.fiveMinutes.rawValue, 300)
        XCTAssertEqual(RefreshInterval.fifteenMinutes.rawValue, 900)
        XCTAssertEqual(RefreshInterval.thirtyMinutes.rawValue, 1800)
        XCTAssertEqual(RefreshInterval.sixtyMinutes.rawValue, 3600)
    }

    func testRefreshintervalStrings() {
        XCTAssertEqual(RefreshInterval.fiveMinutes.title, "5 min")
        XCTAssertEqual(RefreshInterval.fifteenMinutes.title, "15 min")
        XCTAssertEqual(RefreshInterval.thirtyMinutes.title, "30 min")
        XCTAssertEqual(RefreshInterval.sixtyMinutes.title, "60 min")
    }
}
