//
//  WeatherSourceTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 2/12/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

@testable import DatWeatherDoe
import Testing

struct WeatherSourceTests {
    
    @Test
    func locationSource() {
        let locationSource = WeatherSource.location

        #expect(locationSource.title == "Location")
        #expect(locationSource.placeholder == "")
        #expect(locationSource.textHint == "")
    }

    @Test
    func latLongSource() {
        let latLongSource = WeatherSource.latLong

        #expect(latLongSource.title == "Lat/Long")
        #expect(latLongSource.placeholder == "42,42")
        #expect(latLongSource.textHint == "[latitude],[longitude]")
    }
}
