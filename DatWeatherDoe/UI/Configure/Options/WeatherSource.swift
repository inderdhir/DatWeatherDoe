//
//  WeatherSource.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/23/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import Foundation

enum WeatherSource: String, CaseIterable {
    case location, latLong, zipCode

    var title: String {
        switch self {
        case .location:
            return NSLocalizedString("Location", comment: "Weather based on location")
        case .latLong:
            return NSLocalizedString("Lat/Long", comment: "Weather based on Lat/Long")
        case .zipCode:
            return NSLocalizedString("Zip Code", comment: "Weather based on Zip Code")
        }
    }
    
    var menuIndex: Int {
        switch self {
        case .location:
            return 0
        case .latLong:
            return 1
        case .zipCode:
            return 2
        }
    }
    
    var placeholder: String {
        switch self {
        case .location:
            return ""
        case .latLong:
            return "42,42"
        case .zipCode:
            return "10021,us"
        }
    }
    
    var textHint: String {
        switch self {
        case .location:
            return ""
        case .latLong:
            return NSLocalizedString(
                "[latitude],[longitude]",
                comment: "Placeholder hint for entering Lat/Lonet smartindent"
            )
        case .zipCode:
            return NSLocalizedString(
                "[zipcode],[iso 3166 country code]",
                comment: "Placeholder hint for entering zip code"
            )
        }
    }
}
