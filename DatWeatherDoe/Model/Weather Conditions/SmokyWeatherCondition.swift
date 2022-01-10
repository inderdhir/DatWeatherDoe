//
//  SmokyWeatherCondition.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import AppKit
import Foundation

enum SmokyWeatherCondition: String {
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
    
    var image: NSImage? {
        let imageString: String
        
        switch self {
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

    var textualRepresentation: String {
        switch self {
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
