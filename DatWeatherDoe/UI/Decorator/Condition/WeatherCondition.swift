//
//  WeatherCondition.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/29/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import AppKit
import Foundation

enum WeatherCondition {
    case cloudy, partlyCloudy, partlyCloudyNight
    case sunny, clearNight
    case snow
    case heavyRain, freezingRain, lightRain, partlyCloudyRain
    case thunderstorm
    case mist, fog

    static func getFallback(isDay: Bool) -> WeatherCondition {
        isDay ? .sunny : .clearNight
    }

    var symbolName: String {
        switch self {
        case .cloudy:
            "cloud"
        case .partlyCloudy:
            "cloud.sun"
        case .partlyCloudyNight:
            "cloud.moon"
        case .sunny:
            "sun.max"
        case .clearNight:
            "moon"
        case .snow:
            "cloud.snow"
        case .lightRain, .heavyRain, .freezingRain:
            "cloud.rain"
        case .partlyCloudyRain:
            "cloud.sun.rain"
        case .thunderstorm:
            "cloud.bolt.rain"
        case .mist, .fog:
            "cloud.fog"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .cloudy:
            "Cloudy"
        case .partlyCloudy:
            "Partly Cloudy"
        case .partlyCloudyNight:
            "Partly Cloudy"
        case .sunny:
            "Sunny"
        case .clearNight:
            "Clear"
        case .snow:
            "Snow"
        case .lightRain, .heavyRain, .freezingRain:
            "Rainy"
        case .partlyCloudyRain:
            "Partly cloudy with rain"
        case .thunderstorm:
            "Thunderstorm"
        case .mist, .fog:
            "Cloudy with Fog"
        }
    }
}
