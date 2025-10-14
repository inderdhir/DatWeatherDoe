//
//  AirQuality.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 7/1/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import Foundation

// US - EPA standard
enum AirQualityIndex: Int, Decodable {
    case good = 1
    case moderate = 2
    case unhealthyForSensitive = 3
    case unhealthy = 4
    case veryUnhealthy = 5
    case hazardous = 6

    var description: String {
        switch self {
        case .good:
            String(localized: "Good")
        case .moderate:
            String(localized: "Moderate")
        case .unhealthyForSensitive:
            String(localized: "Unhealthy for sensitive groups")
        case .unhealthy:
            String(localized: "Unhealthy")
        case .veryUnhealthy:
            String(localized: "Very unhealthy")
        case .hazardous:
            String(localized: "Hazardous")
        }
    }
}
