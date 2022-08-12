//
//  WeatherCondition.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/29/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Foundation
import AppKit

enum WeatherCondition {
    case cloudy

    case partlyCloudy
    case partlyCloudyNight
    
    case sunny
    case clearNight
    
    case smoky(condition: SmokyWeatherCondition)

    case snow
    
    case heavyRain

    case freezingRain

    case lightRain
    case partlyCloudyRain

    case thunderstorm

    // Used as decoration in the dropdown and not for weather conditions
    case location
    case thermometer
    case windy

    static func getFallback(isNight: Bool) -> WeatherCondition {
        isNight ? .clearNight : .sunny
    }
}
