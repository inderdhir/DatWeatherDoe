//
//  TemperatureForecastTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/25/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class TemperatureForecastTextBuilder {
    
    private let temperatureData: WeatherAPIResponse.TemperatureData
    private let options: TemperatureTextBuilder.Options
    private let upArrowStr = "⬆"
    private let downArrowStr = "⬇"

    init(
        temperatureData: WeatherAPIResponse.TemperatureData,
        options: TemperatureTextBuilder.Options
    ) {
        self.temperatureData = temperatureData
        self.options = options
    }
    
    func build() -> String {        
        let maxTempStr = [upArrowStr, buildTemperature(temperatureData.maxTemperature)]
            .compactMap { $0 }
            .joined()
        let minTempStr = [downArrowStr, buildTemperature(temperatureData.minTemperature)]
            .compactMap { $0 }
            .joined()
        let maxAndMinTempStr = [maxTempStr, minTempStr]
            .compactMap { $0 }
            .joined(separator: " ")
        
        return [buildTemperature(temperatureData.feelsLikeTemperature), maxAndMinTempStr]
            .compactMap { $0 }
            .joined(separator: " - ")
    }
    
    private func buildTemperature(_ temperature: Double) -> String? {
        TemperatureHelpers.getTemperatureWithDegrees(
            temperature,
            unit: options.unit,
            isRoundingOff: options.isRoundingOff,
            isUnitLetterOff: options.isUnitLetterOff,
            isUnitSymbolOff: options.isUnitSymbolOff
        )
    }
}
