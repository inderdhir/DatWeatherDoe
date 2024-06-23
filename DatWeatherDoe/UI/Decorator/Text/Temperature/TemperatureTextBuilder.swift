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
        let temperatureWithDegrees = temperatureCreator.getTemperatureWithDegrees(
            temperatureInMultipleUnits:
            .init(
                fahrenheit: response.temperatureData.tempFahrenheit,
                celsius: response.temperatureData.tempCelsius
            ),
            isRoundingOff: options.isRoundingOff,
            isUnitLetterOff: options.isUnitLetterOff,
            isUnitSymbolOff: options.isUnitSymbolOff
        )
        return temperatureWithDegrees
    }

    private func buildTemperatureText(for unit: TemperatureUnit) -> String? {
        let temperatureForUnit = unit == .fahrenheit ?
            response.temperatureData.tempFahrenheit :
            response.temperatureData.tempCelsius
        let temperatureWithDegrees = temperatureCreator.getTemperatureWithDegrees(
            temperatureForUnit,
            unit: unit,
            isRoundingOff: options.isRoundingOff,
            isUnitLetterOff: options.isUnitLetterOff,
            isUnitSymbolOff: options.isUnitSymbolOff
        )
        return temperatureWithDegrees
    }
}
