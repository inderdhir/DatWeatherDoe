//
//  WeatherError.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/22/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import Foundation

enum WeatherError: LocalizedError {
    case unableToConstructUrl
    case locationError
    case latLongIncorrect
    case networkError

    var errorDescription: String? {
        switch self {
        case .unableToConstructUrl:
            return "Unable to construct URL"
        case .locationError:
            return NSLocalizedString("❗️Location", comment: "Location error when fetching weather")
        case .latLongIncorrect:
            return NSLocalizedString("❗️Lat/Long", comment: "Lat/Long error when fetching weather")
        case .networkError:
            return "🖧"
        }
    }
}
