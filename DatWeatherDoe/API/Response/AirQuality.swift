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
            NSLocalizedString(
                "Good",
                comment: "Air quality index: Good"
            )
        case .moderate:
            NSLocalizedString(
                "Moderate",
                comment: "Air quality index: Moderate"
            )
        case .unhealthyForSensitive:
            NSLocalizedString(
                "Unhealthy for sensitive groups",
                comment: "Air quality index: Unhealthy for sensitive groups"
            )
        case .unhealthy:
            NSLocalizedString(
                "Unhealthy",
                comment: "Air quality index: Unhealthy"
            )
        case .veryUnhealthy:
            NSLocalizedString(
                "Very unhealthy",
                comment: "Air quality index: Very unhealthy"
            )
        case .hazardous:
            NSLocalizedString(
                "Hazardous",
                comment: "Air quality index: Hazardous"
            )
        }
    }
}
