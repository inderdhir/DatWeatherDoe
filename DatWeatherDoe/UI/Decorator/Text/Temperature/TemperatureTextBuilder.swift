//
//  TemperatureTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

protocol TemperatureTextBuilderType {
    func build() -> String
}

final class TemperatureTextBuilder: TemperatureTextBuilderType {
    
    struct Options {
        let unit: TemperatureUnit
        let isRoundingOff: Bool
        let isUnitLetterOff: Bool
        let isUnitSymbolOff: Bool
    }
    
    private let initial: String?
    private let response: WeatherAPIResponse
    private let options: Options
    private let temperatureCreator: TemperatureWithDegreesCreatorType
    private let degreeString = "\u{00B0}"
    
    init(
        initial: String?,
        response: WeatherAPIResponse,
        options: Options,
        temperatureCreator: TemperatureWithDegreesCreatorType
    ) {
        self.initial = initial
        self.response = response
        self.options = options
        self.temperatureCreator = temperatureCreator
    }
    
    func build() -> String {
        if options.unit == .all {
            buildTemperatureTextForAllUnits()
        } else {
            buildTemperatureText(for: options.unit)
        }
    }
    
    private func buildTemperatureTextForAllUnits() -> String {
        let fahrenheitTemperature = buildTemperature(isFahrenheit: true)
        let celsiusTemperature = buildTemperature(isFahrenheit: false)

        let temperatureWithDegrees = temperatureCreator.getTemperatureWithDegrees(
            temperatureInMultipleUnits:
                    .init(fahrenheit: fahrenheitTemperature, celsius: celsiusTemperature),
            unit: options.unit,
            isRoundingOff: options.isRoundingOff,
            isUnitLetterOff: options.isUnitLetterOff,
            isUnitSymbolOff: options.isUnitSymbolOff
        )
        return [initial, temperatureWithDegrees]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
    
    private func buildTemperatureText(for unit: TemperatureUnit) -> String {
        let temperatureForUnit = buildTemperature(isFahrenheit: unit == .fahrenheit)
        let temperatureWithDegrees = temperatureCreator.getTemperatureWithDegrees(
            temperatureForUnit,
            unit: unit,
            isRoundingOff: options.isRoundingOff,
            isUnitLetterOff: options.isUnitLetterOff,
            isUnitSymbolOff: options.isUnitSymbolOff
        )
        return [initial, temperatureWithDegrees]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
    
    private func buildTemperature(isFahrenheit: Bool) -> Double {
        if isFahrenheit {
            TemperatureConverter().convertKelvinToFahrenheit(response.temperatureData.temperature)
        } else {
            TemperatureConverter().convertKelvinToCelsius(response.temperatureData.temperature)
        }
    }
}
