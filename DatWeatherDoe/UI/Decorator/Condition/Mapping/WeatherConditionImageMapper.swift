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
        let imageString: String
        
        switch condition {
        case .cloudy:
            imageString = "Cloudy"
            
        case .partlyCloudy:
            imageString = "Partly Cloudy"
        case .partlyCloudyNight:
            imageString = "Partly Cloudy - Night"
            
        case .sunny:
            imageString = "Sunny"
        case .clearNight:
            imageString = "Clear - Night"
            
        case let .smoky(smokyWeatherCondition):
            return SmokyWeatherConditionImageMapper().map(smokyWeatherCondition)
            
        case .snow:
            imageString = "Snow"
            
        case .heavyRain:
            imageString = "Heavy Rain"
            
        case .freezingRain:
            imageString = "Freezing Rain"
            
        case .lightRain:
            imageString = "Light Rain"
        case .partlyCloudyRain:
            imageString = "Partly Cloudy with Rain"

        case .thunderstorm:
            imageString = "Thunderstorm"

        case .location:
            imageString = "Location"
        case .thermometer:
            imageString = "Thermometer"
        case .windy:
            imageString = "Wind"
        }
        
        return NSImage(named: imageString)
    }
}

private class SmokyWeatherConditionImageMapper {
    func map(_ condition: SmokyWeatherCondition) -> NSImage? {
        let imageString: String
        
        switch condition {
        case .tornado:
            imageString = "Tornado"
        case .squall:
            imageString = "Windy"
        case .ash, .dust, .sand, .sandOrDustWhirls, .fog, .haze, .smoke:
            imageString = "Dust or Fog"
        case .mist:
            imageString = "Mist"
        }
        
        return NSImage(named: imageString)
    }
}
