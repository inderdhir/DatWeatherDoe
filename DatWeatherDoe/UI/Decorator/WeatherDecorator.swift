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
    private let configManager: ConfigManagerType

    @available(macOS 11.0, *)
    private(set) lazy var logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DatWeatherDoe",
        category: "WeatherDecorator"
    )

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
        response: WeatherAPIResponse,
        temperatureUnit: TemperatureUnit,
        isShowingHumidity: Bool
    ) {
        self.configManager = configManager
        self.response = response
        self.temperatureUnit = temperatureUnit
        self.isShowingHumidity = isShowingHumidity
    }

    var textualRepresentation: String? {
        let temperatureString = temperature ?? ""
        guard isShowingHumidity else { return temperatureString }

        let humidityString: String
        if let humidity = humidity {
            humidityString = "/\(humidity)"
        } else {
            humidityString = ""
        }
        return "\(temperatureString)\(humidityString)"
    }

    var weatherCondition: WeatherCondition {
        switch response.weatherId {
        case 801:
            return .partlyCloudy
        case 802...900:
            return .cloudy
        case 700..<800:
            return .mist
        case 600..<700:
            return .snow
        case 520..<600:
            return .partlyCloudyRain
        case 511:
            return .freezingRain
        case 500...504:
            return .heavyRain
        case 300..<500:
            return .lightRain
        case 200..<300:
            return .thunderstorm
        default:
            return .sunny
        }
    }

    private var temperature: String? {
        let isFahrenheit = temperatureUnit == .fahrenheit
        let temperatureInUnits = isFahrenheit ?
            ((response.temperature - 273.15) * 1.8) + 32 : response.temperature - 273.15

        WeatherDecorator.temperatureFormatter.maximumFractionDigits = configManager.isRoundingOffData ? 0 : 1

        guard let formattedString =
                WeatherDecorator.temperatureFormatter.string(from: NSNumber(value: temperatureInUnits)) else {
            if #available(macOS 11.0, *) {
                logger.error("Unable to construct formatted temperature string")
            }
            return nil
        }

        let tempUnit = isFahrenheit ? "F" : "C"
        return "\(formattedString)\u{00B0}\(tempUnit)"
    }

    private var humidity: String? {
        guard let formattedString =
                WeatherDecorator.humidityFormatter.string(from: NSNumber(value: response.humidity)) else {
            if #available(macOS 11.0, *) {
                logger.error("Unable to construct formatted humidity string")
            }
            return nil
        }
        return "\(formattedString)\u{0025}"
    }
}
