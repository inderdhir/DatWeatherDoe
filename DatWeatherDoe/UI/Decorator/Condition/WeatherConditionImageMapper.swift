//
//  WeatherConditionImageMapper.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Cocoa

protocol WeatherConditionImageMapperType {
    func map(_ condition: WeatherCondition) -> NSImage?
}

final class WeatherConditionImageMapper: WeatherConditionImageMapperType {
    func map(_ condition: WeatherCondition) -> NSImage? {
        let symbolName: String
        let accessibilityDescription: String

        switch condition {
        case .cloudy:
            symbolName = "cloud"
            accessibilityDescription = "Cloudy"

        case .partlyCloudy:
            symbolName = "cloud.sun"
            accessibilityDescription = "Partly Cloudy"

        case .partlyCloudyNight:
            symbolName = "cloud.moon"
            accessibilityDescription = "Partly Cloudy"

        case .sunny:
            symbolName = "sun.max"
            accessibilityDescription = "Sunny"

        case .clearNight:
            symbolName = "moon"
            accessibilityDescription = "Clear"

        case .snow:
            symbolName = "cloud.snow"
            accessibilityDescription = "Snow"

        case .lightRain, .heavyRain, .freezingRain:
            symbolName = "cloud.rain"
            accessibilityDescription = "Rainy"

        case .partlyCloudyRain:
            symbolName = "cloud.sun.rain"
            accessibilityDescription = "Partly cloudy with rain"

        case .thunderstorm:
            symbolName = "cloud.bolt.rain"
            accessibilityDescription = "Thunderstorm"

        case .mist, .fog:
            symbolName = "cloud.fog"
            accessibilityDescription = "Cloudy with Fog"
        }

        let config = NSImage.SymbolConfiguration(textStyle: .title2, scale: .medium)
        return NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: accessibilityDescription
        )?.withSymbolConfiguration(config)
    }
}
