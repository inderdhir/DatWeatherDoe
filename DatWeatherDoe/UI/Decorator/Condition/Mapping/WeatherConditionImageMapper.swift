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
        
        switch condition {
        case .cloudy:
            symbolName = "cloud"
            
        case .partlyCloudy:
            symbolName = "cloud.sun"
        case .partlyCloudyNight:
            symbolName = "cloud.moon"
            
        case .sunny:
            symbolName = "sun.max"
        case .clearNight:
            symbolName = "moon"
            
        case let .smoky(smokyWeatherCondition):
            return SmokyWeatherConditionImageMapper().map(smokyWeatherCondition)
            
        case .snow:
            symbolName = "cloud.snow"
            
        case .lightRain, .heavyRain, .freezingRain:
            symbolName = "cloud.rain"
        
        case .partlyCloudyRain:
            symbolName = "cloud.sun.rain"

        case .thunderstorm:
            symbolName = "cloud.bolt.rain"
        }
        
        let config = NSImage.SymbolConfiguration(textStyle: .title2, scale: .medium)
        return NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?.withSymbolConfiguration(config)
    }
}

private class SmokyWeatherConditionImageMapper {
    func map(_ condition: SmokyWeatherCondition) -> NSImage? {
        let symbolName: String
        
        switch condition {
        case .tornado:
            symbolName = "tornado"
        case .squall:
            symbolName = "wind"
        default:
            symbolName = "cloud.fog"
        }
        
        return NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
    }
}
