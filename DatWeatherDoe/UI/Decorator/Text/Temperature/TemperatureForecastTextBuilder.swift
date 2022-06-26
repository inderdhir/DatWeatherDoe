//
//  TemperatureForecastTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/25/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class TemperatureForecastTextBuilder {
        
    static let temperatureIconStr = "🌡"
    
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
        let feelsLikeTempStr = [
            TemperatureForecastTextBuilder.temperatureIconStr,
            buildTemperature(temperatureData.feelsLikeTemperature)
        ]
            .compactMap { $0 }
            .joined(separator: " ")
        
        let maxTempStr = [upArrowStr, buildTemperature(temperatureData.maxTemperature)]
            .compactMap { $0 }
            .joined()
        let minTempStr = [downArrowStr, buildTemperature(temperatureData.minTemperature)]
            .compactMap { $0 }
            .joined()
        let maxAndMinTempStr = [maxTempStr, minTempStr]
            .compactMap { $0 }
            .joined(separator: " ")
        
        return [feelsLikeTempStr, maxAndMinTempStr]
            .compactMap { $0 }
            .joined(separator: " - ")
    }
    
    
    private func buildTemperature(_ temperature: Double) -> String? {
        switch options.unit {
        case .fahrenheit:
            return TemperatureHelpers.getFahrenheitTemperatureWithDegrees(
                temperature,
                isRoundingOff: options.isRoundingOff
            )
        case .celsius:
            return TemperatureHelpers.getCelsiusTemperatureWithDegrees(
                temperature,
                isRoundingOff: options.isRoundingOff
            )
        case .all:
            return TemperatureHelpers.getTemperatureInAllUnits(
                temperature,
                isRoundingOff: options.isRoundingOff
            )
        }
    }
}
