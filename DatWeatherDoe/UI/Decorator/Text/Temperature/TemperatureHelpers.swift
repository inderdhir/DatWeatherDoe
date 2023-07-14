//
//  TemperatureHelpers.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/25/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

final class TemperatureHelpers {
    static let degreeString = "\u{00B0}"
    
    class func getTemperatureWithDegrees(
        _ temperature: Double,
        unit: TemperatureUnit,
        isRoundingOff: Bool,
        isUnitLetterOff: Bool,
        isUnitSymbolOff: Bool
    ) -> String? {
        guard let temperatureString = getFormattedString(
            temperature: temperature,
            isRoundingOff: isRoundingOff,
            isUnitLetterOff: isUnitLetterOff,
            isUnitSymbolOff: isUnitSymbolOff
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
    
    private class func getFormattedString(
        temperature: Double,
        isRoundingOff: Bool,
        isUnitLetterOff: Bool,
        isUnitSymbolOff: Bool
    ) -> String? {
        TemperatureFormatter().getFormattedTemperatureString(
            temperature,
            isRoundingOff: isRoundingOff,
            isUnitLetterOff: isUnitLetterOff,
            isUnitSymbolOff: isUnitSymbolOff
        )
    }

    private class func combineTemperatureWithUnitDegrees(
        temperature: String,
        unit: String,
        isUnitLetterOff: Bool,
        isUnitSymbolOff: Bool
    ) -> String {
        if isUnitLetterOff {
            if isUnitSymbolOff {
                return [temperature,   ""].joined(separator: ""          )
            } else {
                return [temperature,   ""].joined(separator: degreeString)
            }
        } else {
            if isUnitSymbolOff {
                return [temperature, unit].joined(separator: ""          )
            } else {
                return [temperature, unit].joined(separator: degreeString)
            }
        }
    }
}
