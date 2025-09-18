//
//  TemperatureUnitTests.swift
//  DatWeatherDoeTests
//
//  Created by Inder Dhir on 2/12/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

@testable import DatWeatherDoe
import Testing

struct TemperatureUnitTests {
    
    @Test
    func fahrenheit() {
        let fahrenheitUnit = TemperatureUnit.fahrenheit

        #expect(fahrenheitUnit.unitString == "F")
        #expect(fahrenheitUnit.degreesString == "\u{00B0}F")
    }

    @Test
    func celsius() {
        let fahrenheitUnit = TemperatureUnit.celsius

        #expect(fahrenheitUnit.unitString == "C")
        #expect(fahrenheitUnit.degreesString == "\u{00B0}C")
    }

    @Test
    func all() {
        let fahrenheitUnit = TemperatureUnit.all

        #expect(fahrenheitUnit.unitString == "All")
        #expect(fahrenheitUnit.degreesString == "\u{00B0}All")
    }
}
