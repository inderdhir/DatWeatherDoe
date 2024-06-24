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
    private let temperatureData: TemperatureData
    private let forecastTemperatureData: ForecastTemperatureData
    private let options: TemperatureTextBuilder.Options
    private let upArrowStr = "⬆"
    private let downArrowStr = "⬇"
    private let degreeString = "\u{00B0}"

    init(
        temperatureData: TemperatureData,
        forecastTemperatureData: ForecastTemperatureData,
        options: TemperatureTextBuilder.Options
    ) {
        self.temperatureData = temperatureData
        self.forecastTemperatureData = forecastTemperatureData
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
            temperatureData.feelsLikeTempFahrenheit, unit: .fahrenheit
        )
        let feelsLikeTempCelsius = buildFormattedTemperature(
            temperatureData.feelsLikeTempCelsius, unit: .celsius
        )
        let feelsLikeTemperatureCombined = [feelsLikeTempFahrenheit, feelsLikeTempCelsius]
            .compactMap { $0 }
            .joined(separator: " / ")

        let maxTempFahrenheit = buildFormattedTemperature(
            forecastTemperatureData.maxTempF, unit: .fahrenheit
        )
        let maxTempCelsius = buildFormattedTemperature(
            forecastTemperatureData.maxTempC, unit: .celsius
        )
        let maxTempCombined = [maxTempFahrenheit, maxTempCelsius]
            .compactMap { $0 }
            .joined(separator: " / ")
        let maxTempStr = [upArrowStr, maxTempCombined]
            .compactMap { $0 }
            .joined()

        let minTempFahrenheit = buildFormattedTemperature(
            forecastTemperatureData.minTempF, unit: .fahrenheit
        )
        let minTempCelsius = buildFormattedTemperature(
            forecastTemperatureData.minTempC, unit: .celsius
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
        let maxTemp = unit == .fahrenheit ? forecastTemperatureData.maxTempF : forecastTemperatureData.maxTempC
        let formattedMaxTemp = buildFormattedTemperature(maxTemp, unit: unit)
        let maxTempStr = [upArrowStr, formattedMaxTemp]
            .compactMap { $0 }
            .joined()

        let minTemp = unit == .fahrenheit ? forecastTemperatureData.minTempF : forecastTemperatureData.minTempC
        let formatedMinTemp = buildFormattedTemperature(minTemp, unit: unit)
        let minTempStr = [downArrowStr, formatedMinTemp]
            .compactMap { $0 }
            .joined()

        let maxAndMinTempStr = [maxTempStr, minTempStr]
            .compactMap { $0 }
            .joined(separator: " ")

        let feelsLikeTemp = unit == .fahrenheit ?
            temperatureData.feelsLikeTempFahrenheit :
            temperatureData.feelsLikeTempCelsius
        let formattedFeelsLikeTemp = buildFormattedTemperature(feelsLikeTemp, unit: unit)
        return [formattedFeelsLikeTemp, maxAndMinTempStr]
            .compactMap { $0 }
            .joined(separator: " - ")
    }

    private func buildFormattedTemperature(
        _ temperatureForUnit: Double,
        unit: TemperatureUnit
    ) -> String? {
        guard let temperatureString = TemperatureFormatter()
            .getFormattedTemperatureString(temperatureForUnit, isRoundingOff: options.isRoundingOff)
        else {
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
