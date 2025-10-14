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
            "Unable to construct URL"
        case .locationError:
            String(localized: "❗️Location")
        case .latLongIncorrect:
            String(localized: "❗️Lat/Long")
        case .networkError:
            "🖧"
        }
    }
}
