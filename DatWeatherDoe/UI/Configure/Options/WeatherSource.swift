//
//  WeatherSource.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/23/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import Foundation

enum WeatherSource: String, CaseIterable {
    case location, latLong, city

    var title: String {
        switch self {
        case .location:
            return NSLocalizedString("Location", comment: "Weather based on location")
        case .latLong:
            return NSLocalizedString("Lat/Long", comment: "Weather based on Lat/Long")
        case .city:
            return NSLocalizedString("City", comment: "Weather based on City")
        }
    }

    var placeholder: String {
        switch self {
        case .location:
            return ""
        case .latLong:
            return "42,42"
        case .city:
            return "Kyiv,ua"
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
        case .city:
            return NSLocalizedString(
                "[city],[iso 3166 country code]",
                comment: "Placeholder hint for entering city"
            )
        }
    }
}
