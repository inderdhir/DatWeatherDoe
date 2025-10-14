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
            String(localized: "Location")
        case .latLong:
            String(localized: "Lat/Long")
        }
    }

    var placeholder: String {
        switch self {
        case .location:
            ""
        case .latLong:
            "42,42"
        }
    }

    var textHint: String {
        switch self {
        case .location:
            ""
        case .latLong:
            String(localized: "[latitude],[longitude]")
        }
    }
}
