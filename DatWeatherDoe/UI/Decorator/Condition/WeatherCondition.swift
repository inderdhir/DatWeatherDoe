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
}
