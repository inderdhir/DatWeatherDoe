//
//  WeatherCondition.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/29/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Foundation
import AppKit

enum WeatherCondition: String {
    case cloudy = "Cloudy"

    case partlyCloudy = "Partly cloudy"
    case partlyCloudyNight = "Partly cloudy - Night"
    
    case sunny = "Sunny"
    case clearNight = "Clear - Night"

    case tornado = "Tornado"
    case squall = "Squall"
    case ash = "Ash"
    case dust = "Dust"
    case sand = "Sand"
    case fog = "Fog"
    case sandOrDustWhirls = "Sand/Dust Whirls"
    case haze = "Haze"
    case smoke = "Smoke"
    case mist = "Mist"
    
    case snow = "Snow"
    
    case heavyRain = "Heavy rain"

    case freezingRain = "Freezing rain"

    case lightRain = "Light rain"
    case partlyCloudyRain = "Partly cloudy with rain"

    case thunderstorm = "Thunderstorm"
    
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
            
        case .tornado:
            imageString = "Tornado"
        case .squall:
            imageString = "Windy"
        case .ash, .dust, .sand, .sandOrDustWhirls, .fog, .haze, .smoke:
            imageString = "Dust or Fog"
        case .mist:
            imageString = "Mist"
            
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
