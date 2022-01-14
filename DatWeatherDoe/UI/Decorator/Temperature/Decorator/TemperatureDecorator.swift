//
//  TemperatureDecorator.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class TemperatureDecorator {
    
    private let options: TemperatureDecoratorOptions
    private let logger: DatWeatherDoeLoggerType
    private let degreeString = "\u{00B0}"
    
    init(
        options: TemperatureDecoratorOptions,
        logger: DatWeatherDoeLoggerType
    ) {
        self.options = options
        self.logger = logger
    }
    
    func decorate() -> String? {
        if options.unit == .all {
            return getTemperatureInBothUnits()
        } else {
            return getTemperatureForUnit(options.unit)
        }
    }
    
    private func getTemperatureInBothUnits() -> String? {
        let fahrenheitTemperature = getTemperatureForUnit(.fahrenheit)
        let celsiusTemperature = getTemperatureForUnit(.celsius)
        
        guard let fahrenheitTemperature = fahrenheitTemperature,
              let celsiusTemperature = celsiusTemperature else {
                  return nil
              }
        return combineTemperatureStrings(
            fahrenheit: fahrenheitTemperature,
            celsius: celsiusTemperature
        )
    }
    
    private func getTemperatureForUnit(_ unit: TemperatureUnit) -> String? {
        switch unit {
        case .fahrenheit:
            return getFahrenheitTemperatureWithDegrees()
        case .celsius:
            return getCelsiusTemperatureWithDegrees()
        case .all:
            return nil
        }
    }
    
    private func combineTemperatureStrings(fahrenheit: String, celsius: String) -> String {
        [
            [fahrenheit, TemperatureUnit.fahrenheit.unitString]
                .joined(separator: degreeString),
            
            [celsius, TemperatureUnit.celsius.unitString]
                .joined(separator: degreeString),
        ]
            .joined(separator: " / ")
    }
    
    private func getFahrenheitTemperatureWithDegrees() -> String? {
        let temperature = TemperatureConverter().convertKelvinToFahrenheit(options.temperature)
        guard let temperatureString = getFormattedString(temperature: temperature) else {
            return nil
        }
        return combineTemperatureWithUnitDegrees(
            temperature: temperatureString,
            unit: TemperatureUnit.fahrenheit.unitString
        )
    }
    
    private func getCelsiusTemperatureWithDegrees() -> String? {
        let temperature = TemperatureConverter().convertKelvinToCelsius(options.temperature)
        guard let temperatureString = getFormattedString(temperature: temperature) else {
            return nil
        }
        return combineTemperatureWithUnitDegrees(
            temperature: temperatureString,
            unit: TemperatureUnit.celsius.unitString
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
}
