//
//  TemperatureHelpers.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/25/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

final class TemperatureHelpers {
    static let degreeString = "\u{00B0}"
    
    class func getFahrenheitTemperatureWithDegrees(
        _ temperature: Double,
        isRoundingOff: Bool
    ) -> String? {
        let temperature = TemperatureConverter().convertKelvinToFahrenheit(temperature)
        guard let temperatureString = getFormattedString(
            temperature: temperature,
            isRoundingOff: isRoundingOff
        ) else {
            return nil
        }
        
        return combineTemperatureWithUnitDegrees(
            temperature: temperatureString,
            unit: TemperatureUnit.fahrenheit.unitString
        )
    }
    
    class func getCelsiusTemperatureWithDegrees(
        _ temperature: Double,
        isRoundingOff: Bool
    ) -> String? {
        let temperature = TemperatureConverter().convertKelvinToCelsius(temperature)
        guard let temperatureString = getFormattedString(
            temperature: temperature,
            isRoundingOff: isRoundingOff
        ) else {
            return nil
        }
        
        return combineTemperatureWithUnitDegrees(
            temperature: temperatureString,
            unit: TemperatureUnit.celsius.unitString
        )
    }
    
    class func getTemperatureInAllUnits(
        _ temperature: Double,
        isRoundingOff: Bool
    ) -> String? {
        let fahrenheitTemperature = getFahrenheitTemperatureWithDegrees(
            temperature,
            isRoundingOff: isRoundingOff
        )
        let celsiusTemperature = getCelsiusTemperatureWithDegrees(
            temperature,
            isRoundingOff: isRoundingOff
        )
        
        guard let fahrenheitTemperature = fahrenheitTemperature,
              let celsiusTemperature = celsiusTemperature else {
                  return nil
              }
        
        return combineTemperatureWithBothUnitDegrees(
            fahrenheitWithDegrees: fahrenheitTemperature,
            celsiusWithDegrees: celsiusTemperature
        )
    }
    
    private class func combineTemperatureWithUnitDegrees(
        temperature: String,
        unit: String
    ) -> String {
        [temperature, unit].joined(separator: degreeString)
    }
    
    private class func combineTemperatureWithBothUnitDegrees(
        fahrenheitWithDegrees: String,
        celsiusWithDegrees: String
    ) -> String {
        [fahrenheitWithDegrees, celsiusWithDegrees].joined(separator: " / ")
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
}
