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

        case let .smoky(smokyWeatherCondition):
            return SmokyWeatherConditionTextMapper().map(smokyWeatherCondition)

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
        }
    }
}

private class SmokyWeatherConditionTextMapper {
    func map(_ smokyWeatherCondition: SmokyWeatherCondition) -> String {
        switch smokyWeatherCondition {
        case .tornado:
            return NSLocalizedString("Tornado", comment: "Tornado weather condition")
        case .squall:
            return NSLocalizedString("Squall", comment: "Squall weather condition")
        case .ash:
            return NSLocalizedString("Ash", comment: "Ash weather condition")
        case .dust:
            return NSLocalizedString("Dust", comment: "Dust weather condition")
        case .sand:
            return NSLocalizedString("Sand", comment: "Sand weather condition")
        case .fog:
            return NSLocalizedString("Fog", comment: "Fog weather condition")
        case .sandOrDustWhirls:
            return NSLocalizedString("Sand/Dust Whirls", comment: "Sand/Dust Whirls weather condition")
        case .haze:
            return NSLocalizedString("Haze", comment: "Haze weather condition")
        case .smoke:
            return NSLocalizedString("Smoke", comment: "Smoke weather condition")
        case .mist:
            return NSLocalizedString("Mist", comment: "Mist weather condition")
        }
    }
}
