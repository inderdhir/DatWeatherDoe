//
//  TemperatureWithDegreesCreator.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 8/9/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation

struct TemperatureInMultipleUnits {
    let fahrenheit: Double
    let celsius: Double
}

protocol TemperatureWithDegreesCreatorType {
    var degreeString: String { get }

    func getTemperatureWithDegrees(
        temperatureInMultipleUnits: TemperatureInMultipleUnits,
        isRoundingOff: Bool,
        isUnitLetterOff: Bool,
        isUnitSymbolOff: Bool
    ) -> String?

    func getTemperatureWithDegrees(
        _ temperature: Double,
        unit: TemperatureUnit,
        isRoundingOff: Bool,
        isUnitLetterOff: Bool,
        isUnitSymbolOff: Bool
    ) -> String?
}

final class TemperatureWithDegreesCreator: TemperatureWithDegreesCreatorType {
    let degreeString = "\u{00B0}"

    func getTemperatureWithDegrees(
        temperatureInMultipleUnits: TemperatureInMultipleUnits,
        isRoundingOff: Bool,
        isUnitLetterOff: Bool,
        isUnitSymbolOff: Bool
    ) -> String? {
        guard let fahrenheitString = TemperatureFormatter().getFormattedTemperatureString(
            temperatureInMultipleUnits.fahrenheit,
            isRoundingOff: isRoundingOff
        ) else {
            return nil
        }
        guard let celsiusString = TemperatureFormatter().getFormattedTemperatureString(
            temperatureInMultipleUnits.celsius,
            isRoundingOff: isRoundingOff
        ) else {
            return nil
        }

        let formattedFahrenheit = combineTemperatureWithUnitDegrees(
            temperature: fahrenheitString,
            unit: .fahrenheit,
            isUnitLetterOff: isUnitLetterOff,
            isUnitSymbolOff: isUnitSymbolOff
        )
        let formattedCelsius = combineTemperatureWithUnitDegrees(
            temperature: celsiusString,
            unit: .celsius,
            isUnitLetterOff: isUnitLetterOff,
            isUnitSymbolOff: isUnitSymbolOff
        )

        return [formattedFahrenheit, formattedCelsius]
            .joined(separator: " / ")
    }

    func getTemperatureWithDegrees(
        _ temperature: Double,
        unit: TemperatureUnit,
        isRoundingOff: Bool,
        isUnitLetterOff: Bool,
        isUnitSymbolOff: Bool
    ) -> String? {
        guard let temperatureString = TemperatureFormatter().getFormattedTemperatureString(
            temperature,
            isRoundingOff: isRoundingOff
        ) else {
            return nil
        }

        return combineTemperatureWithUnitDegrees(
            temperature: temperatureString,
            unit: unit,
            isUnitLetterOff: isUnitLetterOff,
            isUnitSymbolOff: isUnitSymbolOff
        )
    }

    private func combineTemperatureWithUnitDegrees(
        temperature: String,
        unit: TemperatureUnit,
        isUnitLetterOff: Bool,
        isUnitSymbolOff: Bool
    ) -> String {
        let unitLetter = isUnitLetterOff ? "" : unit.unitString
        let unitSymbol = isUnitSymbolOff ? "" : degreeString
        return [temperature, unitLetter].joined(separator: unitSymbol)
    }
}
