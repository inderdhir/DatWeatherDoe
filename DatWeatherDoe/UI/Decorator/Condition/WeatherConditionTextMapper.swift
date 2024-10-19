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
            NSLocalizedString("Cloudy", comment: "Cloudy weather condition")

        case .partlyCloudy, .partlyCloudyNight:
            NSLocalizedString("Partly cloudy", comment: "Partly cloudy weather condition")

        case .sunny:
            NSLocalizedString("Sunny", comment: "Sunny weather condition")

        case .clearNight:
            NSLocalizedString("Clear", comment: "Clear at night weather condition")

        case .snow:
            NSLocalizedString("Snow", comment: "Snow weather condition")

        case .heavyRain:
            NSLocalizedString("Heavy rain", comment: "Heavy rain weather condition")

        case .freezingRain:
            NSLocalizedString("Freezing rain", comment: "Freezing rain weather condition")

        case .lightRain:
            NSLocalizedString("Light rain", comment: "Light rain weather condition")

        case .partlyCloudyRain:
            NSLocalizedString(
                "Partly cloudy with rain",
                comment: "Partly cloudy with rain weather condition"
            )

        case .thunderstorm:
            NSLocalizedString("Thunderstorm", comment: "Thunderstorm weather condition")

        case .mist:
            NSLocalizedString("Mist", comment: "Mist weather condition")

        case .fog:
            NSLocalizedString("Fog", comment: "Fog weather condition")
        }
    }
}
