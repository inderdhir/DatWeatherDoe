//
//  WeatherRepresentation.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/22/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import Foundation
import os

final class WeatherDecorator: WeatherDecoratorType {
    
    private let degreeString = "\u{00B0}"
    private let percentString = "\u{0025}"
    private let logger: DatWeatherDoeLoggerType
    private let response: WeatherAPIResponse
    private let options: WeatherDecoratorOptions
    
    init(
        logger: DatWeatherDoeLoggerType,
        response: WeatherAPIResponse,
        options: WeatherDecoratorOptions
    ) {
        self.logger = logger
        self.response = response
        self.options = options
    }
    
    func textualRepresentation(
        sunrise: TimeInterval,
        sunset: TimeInterval
    ) -> String {
        let weatherConditionAsText = options.isWeatherConditionAsTextEnabled ?
        weatherCondition(sunrise: sunrise, sunset: sunset).textualRepresentation :
        nil
        
        let weatherConditionAndTempStr = appendTemperaturetoWeatherCondition(
            weatherCondition: weatherConditionAsText
        )
        
        if options.isShowingHumidity {
            return constructWeatherWithHumidityString(weather: weatherConditionAndTempStr)
        } else {
            return weatherConditionAndTempStr
        }
    }
    
    func weatherCondition(
        sunrise: TimeInterval,
        sunset: TimeInterval
    ) -> WeatherCondition {
        switch response.weatherId {
        case 803...804:
            return .cloudy
        case 801...802:
            return Date().isNight(sunrise: sunrise, sunset: sunset) ?
                .partlyCloudyNight : .partlyCloudy
        case 800:
            return Date().isNight(sunrise: sunrise, sunset: sunset) ?
                .clearNight : .sunny
            
        case 701...781:
            return constructSmokyWeatherCondition(
                sunrise: sunrise,
                sunset: sunset
            )
            
        case 600...622:
            return .snow
            
        case 521...531, 502...504:
            return .heavyRain
        case 511:
            return .freezingRain
        case 500...501, 520, 300...321:
            return Date().isNight(sunrise: sunrise, sunset: sunset) ?
                .lightRain : .partlyCloudyRain
            
        case 200...232:
            return .thunderstorm
            
        default:
            return constructFallbackWeatherCondition(
                sunrise: sunrise,
                sunset: sunset
            )
        }
    }
    
    private func appendTemperaturetoWeatherCondition(weatherCondition: String?) -> String {
        [weatherCondition, temperature]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
    
    private func constructWeatherWithHumidityString(weather: String) -> String {
        guard let humidity = humidity else { return weather }
        
        return "\(weather) | \(humidity)"
    }
    
    private func constructSmokyWeatherCondition(
        sunrise: TimeInterval,
        sunset: TimeInterval
    ) -> WeatherCondition {
        switch response.weatherId {
        case 781:
            return .smoky(condition: .tornado)
        case 771:
            return .smoky(condition: .squall)
        case 762:
            return .smoky(condition: .ash)
        case 761:
            return .smoky(condition: .dust)
        case 751:
            return .smoky(condition: .sand)
        case 741:
            return .smoky(condition: .fog)
        case 731:
            return .smoky(condition: .sandOrDustWhirls)
        case 721:
            return .smoky(condition: .haze)
        case 711:
            return .smoky(condition: .smoke)
        case 701:
            return .smoky(condition: .mist)
        default:
            return constructFallbackWeatherCondition(
                sunrise: sunrise,
                sunset: sunset
            )
        }
    }
    
    private func constructFallbackWeatherCondition(
        sunrise: TimeInterval,
        sunset: TimeInterval
    ) -> WeatherCondition {
        Date().isNight(sunrise: sunrise, sunset: sunset) ?
            .clearNight : .sunny
    }
    
    private var temperature: String? {
        setupTemperatureRounding()
        
        if options.temperatureUnit == .all {
            return getTemperatureInBothUnits()
        } else {
            return getTemperatureInSelectedUnit()
        }
    }
    
    private var humidity: String? {
        guard let formattedString =
                WeatherFormatter.humidityFormatter.string(from: NSNumber(value: response.humidity)) else {
                    logger.logError("Unable to construct formatted humidity string")
                    
                    return nil
                }
        
        return "\(formattedString)\(percentString)"
    }
    
    private func setupTemperatureRounding() {
        WeatherFormatter.temperatureFormatter.maximumFractionDigits =
        options.isRoundingOffData ? 0 : 1
    }
    
    private func getTemperatureInBothUnits() -> String? {
        guard let formattedFahrenheitStr = getFormattedFahrenheitString(),
              let formattedCelsiusStr = getFormattedCelsiusString() else {
                  logger.logError("Unable to construct formatted \(TemperatureUnit.all.rawValue) string")
                  
                  return nil
              }
        
        return combineTemperatureString(
            fahrenheit: formattedFahrenheitStr,
            celsius: formattedCelsiusStr
        )
    }
    
    private func getTemperatureInSelectedUnit() -> String? {
        let isFahrenheit = options.temperatureUnit == .fahrenheit
        let temperatureInUnits = isFahrenheit ?
        response.temperature.fahrenheitTemperature :
        response.temperature.celsiusTemperature
        
        guard let formattedString = getFormattedTemperatureString(temperatureInUnits) else {
            logger.logError(
                "Unable to construct formatted \(options.temperatureUnit.rawValue) temperature string"
            )
            
            return nil
        }
        
        let temperatureString = getTemperatureWithoutRoundingIssues(formattedString)
        let unit = isFahrenheit ? "F" : "C"
        return getTemperatureWithDegrees(temperature: temperatureString, unit: unit)
    }
    
    private func getFormattedFahrenheitString() -> String? {
        WeatherFormatter.temperatureFormatter.string(
            from: NSNumber(value: response.temperature.fahrenheitTemperature)
        )
    }
    
    private func getFormattedCelsiusString() -> String? {
        WeatherFormatter.temperatureFormatter.string(
            from: NSNumber(value: response.temperature.celsiusTemperature)
        )
    }
    
    private func combineTemperatureString(fahrenheit: String, celsius: String) -> String {
        [
            [fahrenheit, "F"].joined(separator: degreeString),
            [celsius, "C"].joined(separator: degreeString),
        ]
            .joined(separator: " / ")
    }
    
    private func getFormattedTemperatureString(_ temperature: Double) -> String? {
        WeatherFormatter.temperatureFormatter.string(
            from: NSNumber(value: temperature)
        )
    }
    
    private func getTemperatureWithDegrees(temperature: String, unit: String) -> String {
        [temperature, unit].joined(separator: degreeString)
    }
    
    private func getTemperatureWithoutRoundingIssues(_ temperature: String) -> String {
        guard temperature == "-0" else { return temperature }
        
        return "0"
    }
}

private extension Double {
    var fahrenheitTemperature: Double { ((self - 273.15) * 1.8) + 32 }
    var celsiusTemperature: Double { self - 273.15 }
}

private extension Date {
    func isNight(sunrise: TimeInterval, sunset: TimeInterval) -> Bool {
        timeIntervalSince1970 >= sunset || timeIntervalSince1970 <= sunrise
    }
}
