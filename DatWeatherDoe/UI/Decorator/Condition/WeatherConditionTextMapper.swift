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
            String(localized: "Cloudy", comment: "Cloudy weather condition")

        case .partlyCloudy, .partlyCloudyNight:
            String(localized: "Partly cloudy", comment: "Partly cloudy weather condition")

        case .sunny:
            String(localized: "Sunny", comment: "Sunny weather condition")

        case .clearNight:
            String(localized: "Clear", comment: "Clear at night weather condition")

        case .snow:
            String(localized: "Snow", comment: "Snow weather condition")

        case .heavyRain:
            String(localized: "Heavy rain", comment: "Heavy rain weather condition")

        case .freezingRain:
            String(localized: "Freezing rain", comment: "Freezing rain weather condition")

        case .lightRain:
            String(localized: "Light rain", comment: "Light rain weather condition")

        case .partlyCloudyRain:
            String(
                localized: "Partly cloudy with rain",
                comment: "Partly cloudy with rain weather condition"
            )

        case .thunderstorm:
            String(localized: "Thunderstorm", comment: "Thunderstorm weather condition")

        case .mist:
            String(localized: "Mist", comment: "Mist weather condition")

        case .fog:
            String(localized: "Fog", comment: "Fog weather condition")
        }
    }
}
