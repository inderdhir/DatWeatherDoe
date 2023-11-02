//
//  TemperatureTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

protocol TemperatureTextBuilderType {
    func build() -> String?
}

final class TemperatureTextBuilder: TemperatureTextBuilderType {
    struct Options {
        let unit: TemperatureUnit
        let isRoundingOff: Bool
        let isUnitLetterOff: Bool
        let isUnitSymbolOff: Bool
    }

    private let response: WeatherAPIResponse
    private let options: Options
    private let temperatureCreator: TemperatureWithDegreesCreatorType
    private let degreeString = "\u{00B0}"

    init(
        response: WeatherAPIResponse,
        options: Options,
        temperatureCreator: TemperatureWithDegreesCreatorType
    ) {
        self.response = response
        self.options = options
        self.temperatureCreator = temperatureCreator
    }

    func build() -> String? {
        if options.unit == .all {
            buildTemperatureTextForAllUnits()
        } else {
            buildTemperatureText(for: options.unit)
        }
    }

    private func buildTemperatureTextForAllUnits() -> String? {
        let fahrenheitTemperature = buildTemperature(isFahrenheit: true)
        let celsiusTemperature = buildTemperature(isFahrenheit: false)

        let temperatureWithDegrees = temperatureCreator.getTemperatureWithDegrees(
            temperatureInMultipleUnits:
            .init(fahrenheit: fahrenheitTemperature, celsius: celsiusTemperature),
            isRoundingOff: options.isRoundingOff,
            isUnitLetterOff: options.isUnitLetterOff,
            isUnitSymbolOff: options.isUnitSymbolOff
        )
        return temperatureWithDegrees
    }

    private func buildTemperatureText(for unit: TemperatureUnit) -> String? {
        let temperatureForUnit = buildTemperature(isFahrenheit: unit == .fahrenheit)
        let temperatureWithDegrees = temperatureCreator.getTemperatureWithDegrees(
            temperatureForUnit,
            unit: unit,
            isRoundingOff: options.isRoundingOff,
            isUnitLetterOff: options.isUnitLetterOff,
            isUnitSymbolOff: options.isUnitSymbolOff
        )
        return temperatureWithDegrees
    }

    private func buildTemperature(isFahrenheit: Bool) -> Double {
        if isFahrenheit {
            TemperatureConverter().convertKelvinToFahrenheit(response.temperatureData.temperature)
        } else {
            TemperatureConverter().convertKelvinToCelsius(response.temperatureData.temperature)
        }
    }
}
