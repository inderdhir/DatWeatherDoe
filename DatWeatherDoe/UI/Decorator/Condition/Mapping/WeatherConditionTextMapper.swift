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
            return NSLocalizedString("Cloudy", comment: "Cloudy weather condition")

        case .partlyCloudy, .partlyCloudyNight:
            return NSLocalizedString("Partly cloudy", comment: "Partly cloudy weather condition")

        case .sunny:
            return NSLocalizedString("Sunny", comment: "Sunny weather condition")

        case .clearNight:
            return NSLocalizedString("Clear", comment: "Clear at night weather condition")

        case .snow:
            return NSLocalizedString("Snow", comment: "Snow weather condition")

        case .heavyRain:
            return NSLocalizedString("Heavy rain", comment: "Heavy rain weather condition")

        case .freezingRain:
            return NSLocalizedString("Freezing rain", comment: "Freezing rain weather condition")

        case .lightRain:
            return NSLocalizedString("Light rain", comment: "Light rain weather condition")

        case .partlyCloudyRain:
            return NSLocalizedString(
                "Partly cloudy with rain",
                comment: "Partly cloudy with rain weather condition"
            )

        case .thunderstorm:
            return NSLocalizedString("Thunderstorm", comment: "Thunderstorm weather condition")

        case .mist:
            return NSLocalizedString("Mist", comment: "Mist weather condition")

        case .fog:
            return NSLocalizedString("Fog", comment: "Fog weather condition")
        }
    }
}
