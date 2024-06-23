//
//  WeatherSource.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/23/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import Foundation

enum WeatherSource: String, CaseIterable {
    case location, latLong

    var title: String {
        switch self {
        case .location:
            return NSLocalizedString("Location", comment: "Weather based on location")
        case .latLong:
            return NSLocalizedString("Lat/Long", comment: "Weather based on Lat/Long")
        }
    }

    var placeholder: String {
        switch self {
        case .location:
            return ""
        case .latLong:
            return "42,42"
        }
    }

    var textHint: String {
        switch self {
        case .location:
            return ""
        case .latLong:
            return NSLocalizedString(
                "[latitude],[longitude]",
                comment: "Placeholder hint for entering Lat/Long"
            )
        }
    }
}
