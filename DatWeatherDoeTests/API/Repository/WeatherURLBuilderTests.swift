//
//  WeatherURLBuilderTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 1/25/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

@testable import DatWeatherDoe
import Foundation
import Testing

struct WeatherURLBuilderTests {
    
    @Test func testBuild() async throws {
        let urlString = try WeatherURLBuilder(
            appId: "123456",
            location: .init(latitude: 42, longitude: 42)
        ).build().absoluteString
        #expect(urlString == "https://api.weatherapi.com/v1/forecast.json?key=123456&aqi=yes&q=42.0,42.0&dt=\(parsedDateToday)")
    }

    private var parsedDateToday: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
}
