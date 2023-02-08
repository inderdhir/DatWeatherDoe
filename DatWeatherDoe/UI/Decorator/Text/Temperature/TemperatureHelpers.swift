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
        isRoundingOff: Bool
    ) -> String? {
        guard let temperatureString = getFormattedString(
            temperature: temperature,
            isRoundingOff: isRoundingOff
        ) else {
            return nil
        }
        
        return combineTemperatureWithUnitDegrees(
            temperature: temperatureString,
            unit: unit.unitString
        )
    }
    
    private class func getFormattedString(
        temperature: Double,
        isRoundingOff: Bool
    ) -> String? {
        TemperatureFormatter().getFormattedTemperatureString(
            temperature,
            isRoundingOff: isRoundingOff
        )
    }
    
    private class func combineTemperatureWithUnitDegrees(
        temperature: String,
        unit: String
    ) -> String {
        [temperature, unit].joined(separator: degreeString)
    }
}
