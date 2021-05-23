//
//  WeatherSource.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/23/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

enum WeatherSource: String, CaseIterable {
    case location, latLong, zipCode

    var title: String {
        switch self {
        case .location:
            return "Location"
        case .latLong:
            return "Lat/Long"
        case .zipCode:
            return "Zip Code"
        }
    }
}
