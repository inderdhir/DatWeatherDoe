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
        if options.unit == .all {
            buildTemperatureForAllUnits()
        } else {
            buildTemperatureForUnit(options.unit)
        }
    }
    
    private func buildTemperatureForAllUnits() -> String {
        let feelsLikeTempFahrenheit = buildFormattedTemperature(
            temperatureData.feelsLikeTemperature, unit: .fahrenheit
        )
        let feelsLikeTempCelsius = buildFormattedTemperature(
            temperatureData.feelsLikeTemperature, unit: .celsius
        )
        let feelsLikeTemperatureCombined = [feelsLikeTempFahrenheit, feelsLikeTempCelsius]
            .compactMap { $0 }
            .joined(separator: " / ")
        
        let maxTempFahrenheit = buildFormattedTemperature(
            temperatureData.maxTemperature, unit: .fahrenheit
        )
        let maxTempCelsius = buildFormattedTemperature(
            temperatureData.maxTemperature, unit: .celsius
        )
        let maxTempCombined = [maxTempFahrenheit, maxTempCelsius]
            .compactMap { $0 }
            .joined(separator: " / ")
        let maxTempStr = [upArrowStr, maxTempCombined]
            .compactMap { $0 }
            .joined()
        
        let minTempFahrenheit = buildFormattedTemperature(
            temperatureData.minTemperature, unit: .fahrenheit
        )
        let minTempCelsius = buildFormattedTemperature(
            temperatureData.minTemperature, unit: .celsius
        )
        let minTempCombined = [minTempFahrenheit, minTempCelsius]
            .compactMap { $0 }
            .joined(separator: " / ")
        let minTempStr = [downArrowStr, minTempCombined]
            .compactMap { $0 }
            .joined()
        
        let maxAndMinTempStr = [maxTempStr, minTempStr]
            .compactMap { $0 }
            .joined(separator: " ")
        return [feelsLikeTemperatureCombined, maxAndMinTempStr]
            .compactMap { $0 }
            .joined(separator: " - ")
    }
    
    private func buildTemperatureForUnit(_ unit: TemperatureUnit) -> String {
        let maxTemperature = buildFormattedTemperature(temperatureData.maxTemperature, unit: unit)
        let maxTempStr = [upArrowStr, maxTemperature]
            .compactMap { $0 }
            .joined()
        
        let minTemperature = buildFormattedTemperature(temperatureData.minTemperature, unit: unit)
        let minTempStr = [downArrowStr, minTemperature]
            .compactMap { $0 }
            .joined()
        
        let maxAndMinTempStr = [maxTempStr, minTempStr]
            .compactMap { $0 }
            .joined(separator: " ")
        
        let feelsLikeTemperature = buildFormattedTemperature(temperatureData.feelsLikeTemperature, unit: unit)
        return [feelsLikeTemperature, maxAndMinTempStr]
            .compactMap { $0 }
            .joined(separator: " - ")
    }
    
    private func buildFormattedTemperature(
        _ kelvinTemperature: Double,
        unit: TemperatureUnit
    ) -> String? {
        let temperatureForUnit = if unit == .fahrenheit {
            TemperatureConverter().convertKelvinToFahrenheit(kelvinTemperature)
        } else {
            TemperatureConverter().convertKelvinToCelsius(kelvinTemperature)
        }
        
        guard let temperatureString = TemperatureFormatter()
            .getFormattedTemperatureString(temperatureForUnit, isRoundingOff: options.isRoundingOff) else {
            return nil
        }
        
        return combineTemperatureWithUnitDegrees(
            temperature: temperatureString,
            unit: unit.unitString,
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
