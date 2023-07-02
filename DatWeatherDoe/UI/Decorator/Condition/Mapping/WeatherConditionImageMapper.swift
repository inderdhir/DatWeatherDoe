//
//  WeatherConditionImageMapper.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Cocoa

final class WeatherConditionImageMapper {
    
    func map(_ condition: WeatherCondition) -> NSImage? {
        let symbolName: String
        let accessibilityDescription: String
        
        switch condition {
        case .cloudy:
            symbolName = "cloud"
            accessibilityDescription = "Cloudy"
            
        case .partlyCloudy:
            symbolName = "cloud.sun"
            accessibilityDescription = "Partly Cloudy"
        case .partlyCloudyNight:
            symbolName = "cloud.moon"
            accessibilityDescription = "Partly Cloudy"
            
        case .sunny:
            symbolName = "sun.max"
            accessibilityDescription = "Sunny"
        case .clearNight:
            symbolName = "moon"
            accessibilityDescription = "Clear"
            
        case let .smoky(smokyWeatherCondition):
            return SmokyWeatherConditionImageMapper().map(smokyWeatherCondition)
            
        case .snow:
            symbolName = "cloud.snow"
            accessibilityDescription = "Snow"
            
        case .lightRain, .heavyRain, .freezingRain:
            symbolName = "cloud.rain"
            accessibilityDescription = "Rainy"
        
        case .partlyCloudyRain:
            symbolName = "cloud.sun.rain"
            accessibilityDescription = "Partly cloudy with rain"

        case .thunderstorm:
            symbolName = "cloud.bolt.rain"
            accessibilityDescription = "Thunderstorm"
        }
        
        let config = NSImage.SymbolConfiguration(textStyle: .title2, scale: .medium)
        return NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: accessibilityDescription
        )?.withSymbolConfiguration(config)
    }
}

private class SmokyWeatherConditionImageMapper {
    func map(_ condition: SmokyWeatherCondition) -> NSImage? {
        let symbolName: String
        let accessibilityDescription: String
        
        switch condition {
        case .tornado:
            symbolName = "tornado"
            accessibilityDescription = "Tornado"
        case .squall:
            symbolName = "wind"
            accessibilityDescription = "Squall"
        default:
            symbolName = "cloud.fog"
            accessibilityDescription = "Cloudy with Fog"
        }
        
        return NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: accessibilityDescription
        )
    }
}
