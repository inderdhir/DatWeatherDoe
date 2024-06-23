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
    private let response: WeatherAPIResponse
    private let options: TemperatureTextBuilder.Options
    private let upArrowStr = "⬆"
    private let downArrowStr = "⬇"
    private let degreeString = "\u{00B0}"

    init(
        response: WeatherAPIResponse,
        options: TemperatureTextBuilder.Options
    ) {
        self.response = response
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
        let feelsLikeTemperatureCombined = [
            String(response.temperatureData.feelsLikeTempFahrenheit),
            String(response.temperatureData.feelsLikeTempCelsius)
        ]
            .compactMap { $0 }
            .joined(separator: " / ")

        let maxTempCombined = [
            String(response.forecastDayData.temp.maxTempF),
            String(response.forecastDayData.temp.maxTempC)
        ]
            .compactMap { $0 }
            .joined(separator: " / ")
        let maxTempStr = [upArrowStr, maxTempCombined]
            .compactMap { $0 }
            .joined()

        let minTempCombined = [
            String(response.forecastDayData.temp.minTempF),
            String(response.forecastDayData.temp.minTempC)
        ]
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
        let maxTemp, minTemp, feelsLikeTemp: Double
        if unit == .fahrenheit {
            maxTemp = response.forecastDayData.temp.maxTempF
            minTemp = response.forecastDayData.temp.minTempF
            feelsLikeTemp = response.temperatureData.feelsLikeTempFahrenheit
        } else {
            maxTemp = response.forecastDayData.temp.maxTempC
            minTemp = response.forecastDayData.temp.minTempC
            feelsLikeTemp = response.temperatureData.feelsLikeTempCelsius
        }
        
        let maxTemperatureWithDegrees = combineTemperatureWithUnitDegrees(
            temperature: String(maxTemp),
            unit: unit.unitString,
            isUnitLetterOff: options.isUnitLetterOff,
            isUnitSymbolOff: options.isUnitSymbolOff
        )
        let maxTempStr = [upArrowStr, maxTemperatureWithDegrees]
            .compactMap { $0 }
            .joined()
        
        let minTemperatureWithDegrees = combineTemperatureWithUnitDegrees(
            temperature: String(minTemp),
            unit: unit.unitString,
            isUnitLetterOff: options.isUnitLetterOff,
            isUnitSymbolOff: options.isUnitSymbolOff
        )
        let minTempStr = [downArrowStr, minTemperatureWithDegrees]
            .compactMap { $0 }
            .joined()

        let maxAndMinTempStr = [maxTempStr, minTempStr]
            .compactMap { $0 }
            .joined(separator: " ")
        
        let feelsLikeTempWithDegrees = combineTemperatureWithUnitDegrees(
            temperature: String(feelsLikeTemp),
            unit: unit.unitString,
            isUnitLetterOff: options.isUnitLetterOff,
            isUnitSymbolOff: options.isUnitSymbolOff
        )
        
        return [feelsLikeTempWithDegrees, maxAndMinTempStr]
            .compactMap { $0 }
            .joined(separator: " - ")
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
