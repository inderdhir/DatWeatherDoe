//
//  TemperatureWithDegreesCreator.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 8/9/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation

protocol TemperatureWithDegreesCreatorType {
    var degreeString: String { get }
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
            unit: unit.unitString,
            isUnitLetterOff: isUnitLetterOff,
            isUnitSymbolOff: isUnitSymbolOff
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
