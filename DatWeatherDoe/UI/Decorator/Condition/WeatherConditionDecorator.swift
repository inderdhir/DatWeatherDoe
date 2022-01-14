//
//  WeatherConditionDecorator.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class WeatherConditionDecorator {
    
    private let sunrise: TimeInterval
    private let sunset: TimeInterval
    private let weatherId: Int
    
    init(
        sunrise: TimeInterval,
        sunset: TimeInterval,
        weatherId: Int
    ) {
        self.sunrise = sunrise
        self.sunset = sunset
        self.weatherId = weatherId
    }
    
    func decorate() -> WeatherCondition {
        switch weatherId {
        case 803...804:
            return .cloudy
        case 801...802:
            return Date().isNight(sunrise: sunrise, sunset: sunset) ?
                .partlyCloudyNight : .partlyCloudy
        case 800:
            return Date().isNight(sunrise: sunrise, sunset: sunset) ?
                .clearNight : .sunny
            
        case 701...781:
            return decorateWithSmokyCondition(weatherId)
            
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
            return decorateWithFallbackWeatherCondition()
        }
    }
    
    private func decorateWithSmokyCondition(_ weatherId: Int) -> WeatherCondition {
        switch weatherId {
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
            return decorateWithFallbackWeatherCondition()
        }
    }
    
    private func decorateWithFallbackWeatherCondition() -> WeatherCondition {
        Date().isNight(sunrise: sunrise, sunset: sunset) ?
            .clearNight : .sunny
    }
}

private extension Date {
    func isNight(sunrise: TimeInterval, sunset: TimeInterval) -> Bool {
        timeIntervalSince1970 >= sunset || timeIntervalSince1970 <= sunrise
    }
}
