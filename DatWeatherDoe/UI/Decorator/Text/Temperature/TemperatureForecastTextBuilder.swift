//
//  TemperatureForecastTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/25/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

protocol TemperatureForecastTextBuilderType {
    func build() -> String
}

final class TemperatureForecastTextBuilder: TemperatureForecastTextBuilderType {
    
    private let temperatureData: WeatherAPIResponse.TemperatureData
    private let options: TemperatureTextBuilder.Options
    private let upArrowStr = "⬆"
    private let downArrowStr = "⬇"
    private let degreeString = "\u{00B0}"

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
        guard let temperatureString = TemperatureFormatter()
            .getFormattedTemperatureString(temperature, isRoundingOff: options.isRoundingOff) else {
            return nil
        }
        
        return combineTemperatureWithUnitDegrees(
            temperature: temperatureString,
            unit: options.unit.unitString,
            isUnitLetterOff: options.isUnitLetterOff,
            isUnitSymbolOff: options.isUnitSymbolOff
        )
    }

    private func combineTemperatureWithUnitDegrees(
        temperature: String,
        unit: String,
        isUnitLetterOff: Bool,
        isUnitSymbolOff: Bool
    ) -> String {
        let unitLetter = isUnitLetterOff ? "" : unit
        let unitSymbol = isUnitSymbolOff ? "" : degreeString
        return [temperature, unitLetter].joined(separator: unitSymbol)
    }
}
