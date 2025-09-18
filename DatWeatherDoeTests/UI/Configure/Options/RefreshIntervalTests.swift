//
//  RefreshIntervalTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 2/12/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

@testable import DatWeatherDoe
import Testing

struct RefreshIntervalTests {
    
    @Test
    func refreshIntervalTimes() {
        #expect(RefreshInterval.fiveMinutes.rawValue == 300)
        #expect(RefreshInterval.fifteenMinutes.rawValue == 900)
        #expect(RefreshInterval.thirtyMinutes.rawValue == 1800)
        #expect(RefreshInterval.sixtyMinutes.rawValue == 3600)
    }

    @Test
    func refreshintervalStrings() {
        #expect(RefreshInterval.fiveMinutes.title == "5 min")
        #expect(RefreshInterval.fifteenMinutes.title == "15 min")
        #expect(RefreshInterval.thirtyMinutes.title == "30 min")
        #expect(RefreshInterval.sixtyMinutes.title == "60 min")
    }
}
