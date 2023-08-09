//
//  WindDirection.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 8/8/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation

enum WindDirection: String {
    case north          = "N"
    case northNorthEast = "NNE"
    case northEast      = "NE"
    case eastNorthEast  = "ENE"
    case east           = "E"
    case eastSouthEast  = "ESE"
    case southEast      = "SE"
    case southSouthEast = "SSE"
    case south          = "S"
    case southSouthWest = "SSW"
    case southWest      = "SW"
    case westSouthWest  = "WSW"
    case west           = "W"
    case westNorthWest  = "WNW"
    case northWest      = "NW"
    case northNorthWest = "NNW"
    
    var direction: String {
        NSLocalizedString(rawValue, comment: "Wind Direction")
    }
}
