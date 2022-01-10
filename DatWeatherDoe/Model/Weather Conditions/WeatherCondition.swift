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
    
    var image: NSImage? {
        let imageString: String
        
        switch self {
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
            
        case let .smoky(condition):
            return condition.image
            
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
        }
        
        return NSImage(named: imageString)
    }

    var textualRepresentation: String {
        switch self {
        case .cloudy:
            return NSLocalizedString("Cloudy", comment: "Cloudy weather condition")
            
        case .partlyCloudy, .partlyCloudyNight:
            return NSLocalizedString("Partly cloudy", comment: "Partly cloudy weather condition")
            
        case .sunny:
            return NSLocalizedString("Sunny", comment: "Sunny weather condition")
        case .clearNight:
            return NSLocalizedString("Clear", comment: "Clear at night weather condition")
            
        case let .smoky(condition):
            return condition.textualRepresentation
            
        case .snow:
            return NSLocalizedString("Snow", comment: "Snow weather condition")
            
        case .heavyRain:
            return NSLocalizedString("Heavy rain", comment: "Heavy rain weather condition")
            
        case .freezingRain:
            return NSLocalizedString("Freezing rain", comment: "Freezing rain weather condition")
            
        case .lightRain:
            return NSLocalizedString("Light rain", comment: "Light rain weather condition")
        case .partlyCloudyRain:
            return NSLocalizedString("Partly cloudy with rain", comment: "Partly cloudy with rain weather condition")
       
        case .thunderstorm:
            return NSLocalizedString("Thunderstorm", comment: "Thunderstorm weather condition")
        }
    }
}
