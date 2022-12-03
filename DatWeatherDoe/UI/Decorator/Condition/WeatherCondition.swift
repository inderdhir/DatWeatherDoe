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

    case partlyCloudy, partlyCloudyNight
    case sunny, clearNight

    case smoky(condition: SmokyWeatherCondition)

    case snow

    case heavyRain
    case freezingRain
    case lightRain
    case partlyCloudyRain

    case thunderstorm

    static func getFallback(isNight: Bool) -> WeatherCondition {
        isNight ? .clearNight : .sunny
    }
}
