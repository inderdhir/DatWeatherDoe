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

    let response: WeatherAPIResponse
    let temperatureUnit: TemperatureUnit
    let isShowingHumidity: Bool
    private let degreeString = "\u{00B0}"
    private let configManager: ConfigManagerType
    private let logger: DatWeatherDoeLoggerType

    private static let temperatureFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .halfUp
        return formatter
    }()

    private static let humidityFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    init(
        configManager: ConfigManagerType,
        logger: DatWeatherDoeLoggerType,
        response: WeatherAPIResponse,
        temperatureUnit: TemperatureUnit,
        isShowingHumidity: Bool
    ) {
        self.configManager = configManager
        self.logger = logger
        self.response = response
        self.temperatureUnit = temperatureUnit
        self.isShowingHumidity = isShowingHumidity
    }

    func textualRepresentation(
        sunrise: TimeInterval,
        sunset: TimeInterval
    ) -> String {
        let weatherConditionAndTempStr = [
            configManager.isWeatherConditionAsTextEnabled ?
                weatherCondition(sunrise: sunrise, sunset: sunset).textualRepresentation :
                nil,
            temperature
        ]
        .compactMap { $0 }
        .joined(separator: ", ")

        guard configManager.isShowingHumidity, let humidity = humidity else {
            return weatherConditionAndTempStr
        }
        return "\(weatherConditionAndTempStr) | \(humidity)"
    }

    func weatherCondition(
        sunrise: TimeInterval,
        sunset: TimeInterval
    ) -> WeatherCondition {
        switch response.weatherId {
        case 801:
            return Date().isNight(sunrise: sunrise, sunset: sunset) ?
                .partlyCloudyNight : .partlyCloudy
        case 802...900:
            return .cloudy
        case 700..<800:
            return .mist
        case 600..<700:
            return .snow
        case 520..<600:
            return Date().isNight(sunrise: sunrise, sunset: sunset) ?
                .lightRain : .partlyCloudyRain
        case 511:
            return .freezingRain
        case 500...504:
            return .heavyRain
        case 300..<500:
            return .lightRain
        case 200..<300:
            return .thunderstorm
        default:
            return Date().isNight(sunrise: sunrise, sunset: sunset) ?
                .clearNight : .sunny
        }
    }

    private var temperature: String? {
        WeatherDecorator.temperatureFormatter.maximumFractionDigits = configManager.isRoundingOffData ? 0 : 1

        // All
        guard temperatureUnit != .all else {
            guard let formattedFahrenheitStr =
                    WeatherDecorator.temperatureFormatter.string(
                        from: NSNumber(value: response.temperature.fahrenheitTemperature)
                    ),
                  let formattedCelsiusStr = WeatherDecorator.temperatureFormatter.string(
                    from: NSNumber(value: response.temperature.celsiusTemperature)
                  ) else {
                logger.logError("Unable to construct formatted \(TemperatureUnit.all.rawValue) string")

                return nil
            }
            return [
                [formattedFahrenheitStr, "F"].joined(separator: degreeString),
                [formattedCelsiusStr, "C"].joined(separator: degreeString),
            ]
            .joined(separator: " / ")
        }

        // F or C
        let isFahrenheit = temperatureUnit == .fahrenheit
        let temperatureInUnits = isFahrenheit ?
            response.temperature.fahrenheitTemperature : response.temperature.celsiusTemperature
        guard let formattedString =
                WeatherDecorator.temperatureFormatter.string(from: NSNumber(value: temperatureInUnits)) else {
            logger.logError("Unable to construct formatted \(temperatureUnit.rawValue) temperature string")

            return nil
        }

        return [formattedString, isFahrenheit ? "F" : "C"].joined(separator: degreeString)
    }

    private var humidity: String? {
        guard let formattedString =
                WeatherDecorator.humidityFormatter.string(from: NSNumber(value: response.humidity)) else {
            logger.logError("Unable to construct formatted humidity string")

            return nil
        }
        return "\(formattedString)\u{0025}"
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
