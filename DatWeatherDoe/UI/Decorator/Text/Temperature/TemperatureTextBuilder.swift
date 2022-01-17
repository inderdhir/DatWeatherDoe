//
//  TemperatureTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

final class TemperatureTextBuilder {
    
    struct Options {
        let unit: TemperatureUnit
        let isRoundingOff: Bool
    }
    
    private let initial: String?
    private let response: WeatherAPIResponse
    private let options: Options
    private let degreeString = "\u{00B0}"
    
    init(
        initial: String?,
        response: WeatherAPIResponse,
        options: Options
    ) {
        self.initial = initial
        self.response = response
        self.options = options
    }
    
    func build() -> String {
        [initial, buildTemperature()]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
    
    private func buildTemperature() -> String? {
        switch options.unit {
        case .fahrenheit:
            return getFahrenheitTemperatureWithDegrees()
        case .celsius:
            return getCelsiusTemperatureWithDegrees()
        case .all:
            return getTemperatureInAllUnits()
        }
    }
    
    private func getFahrenheitTemperatureWithDegrees() -> String? {
        let temperature = TemperatureConverter().convertKelvinToFahrenheit(response.temperature)
        guard let temperatureString = getFormattedString(temperature: temperature) else {
            return nil
        }
        
        return combineTemperatureWithUnitDegrees(
            temperature: temperatureString,
            unit: TemperatureUnit.fahrenheit.unitString
        )
    }
    
    private func getCelsiusTemperatureWithDegrees() -> String? {
        let temperature = TemperatureConverter().convertKelvinToCelsius(response.temperature)
        guard let temperatureString = getFormattedString(temperature: temperature) else {
            return nil
        }
        
        return combineTemperatureWithUnitDegrees(
            temperature: temperatureString,
            unit: TemperatureUnit.celsius.unitString
        )
    }
    
    private func getTemperatureInAllUnits() -> String? {
        let fahrenheitTemperature = getFahrenheitTemperatureWithDegrees()
        let celsiusTemperature = getCelsiusTemperatureWithDegrees()
        
        guard let fahrenheitTemperature = fahrenheitTemperature,
              let celsiusTemperature = celsiusTemperature else {
                  return nil
              }
        
        return combineTemperatureWithBothUnitDegrees(
            fahrenheitWithDegrees: fahrenheitTemperature,
            celsiusWithDegrees: celsiusTemperature
        )
    }
    
    private func getFormattedString(temperature: Double) -> String? {
        TemperatureFormatter().getFormattedTemperatureString(
            temperature,
            isRoundingOff: options.isRoundingOff
        )
    }
    
    private func combineTemperatureWithUnitDegrees(temperature: String, unit: String) -> String {
        [temperature, unit].joined(separator: degreeString)
    }
    
    private func combineTemperatureWithBothUnitDegrees(
        fahrenheitWithDegrees: String,
        celsiusWithDegrees: String
    ) -> String {
        [fahrenheitWithDegrees, celsiusWithDegrees].joined(separator: " / ")
    }
}
