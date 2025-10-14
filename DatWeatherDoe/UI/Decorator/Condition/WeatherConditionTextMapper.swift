//
//  WeatherConditionTextMapper.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

protocol WeatherConditionTextMapperType {
    func map(_ condition: WeatherCondition) -> String
}

final class WeatherConditionTextMapper: WeatherConditionTextMapperType {
    func map(_ condition: WeatherCondition) -> String {
        switch condition {
        case .cloudy:
            String(localized: "Cloudy")

        case .partlyCloudy, .partlyCloudyNight:
            String(localized: "Partly cloudy")

        case .sunny:
            String(localized: "Sunny")

        case .clearNight:
            String(localized: "Clear")

        case .snow:
            String(localized: "Snow")

        case .heavyRain:
            String(localized: "Heavy rain")

        case .freezingRain:
            String(localized: "Freezing rain")

        case .lightRain:
            String(localized: "Light rain")

        case .partlyCloudyRain:
            String(localized: "Partly cloudy with rain")

        case .thunderstorm:
            String(localized: "Thunderstorm")

        case .mist:
            String(localized: "Mist")

        case .fog:
            String(localized: "Fog")
        }
    }
}
