//
//  DropdownIcon.swift
//  DatWeatherDoe
//
//  Created by Markus Mayer on 2022-11-21.
//  Copyright © 2022 Markus Mayer.
//

// Icons used by the dropdown menu
enum DropdownIcon {
    case location
    case thermometer
    case sun
    case wind
    case uvIndexAndAirQualityText

    var symbolName: String {
        switch self {
        case .location:
            "location.north.circle"
        case .thermometer:
            "thermometer.snowflake.circle"
        case .sun:
            "sun.horizon.circle"
        case .wind:
            "wind.circle"
        case .uvIndexAndAirQualityText:
            "sun.max.circle"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .location:
            "Location"
        case .thermometer:
            "Temperature"
        case .sun:
            "Sunrise and Sunset"
        case .wind:
            "Wind data"
        case .uvIndexAndAirQualityText:
            "UV Index and Air Quality Index"
        }
    }
}
