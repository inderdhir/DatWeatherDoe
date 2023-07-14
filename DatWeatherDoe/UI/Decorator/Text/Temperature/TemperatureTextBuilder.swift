//
//  TemperatureTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

final class TemperatureTextBuilder {
    
    struct Options {
        let unit: TemperatureUnit
        let isRoundingOff: Bool
        let isUnitLetterOff: Bool
        let isUnitSymbolOff: Bool
    }
    
    private let initial: String?
    private let response: WeatherAPIResponse
    private let options: Options
    private let degreeString = "\u{00B0}"
    
    init(
        initial: String?,
        response: WeatherAPIResponse,
        options: Options
    ) {
        self.initial = initial
        self.response = response
        self.options = options
    }
    
    func build() -> String {
        let temperature = TemperatureHelpers.getTemperatureWithDegrees(
            response.temperatureData.temperature,
            unit: options.unit,
            isRoundingOff: options.isRoundingOff,
            isUnitLetterOff: options.isUnitLetterOff,
            isUnitSymbolOff: options.isUnitSymbolOff
        )
        return [initial, temperature]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
