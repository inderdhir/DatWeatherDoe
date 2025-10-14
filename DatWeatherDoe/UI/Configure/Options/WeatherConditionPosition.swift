//
//  WeatherConditionPosition.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 3/27/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import Foundation

enum WeatherConditionPosition: String, Identifiable {
    case beforeTemperature, afterTemperature

    var id: Self { self }

    var title: String {
        switch self {
        case .beforeTemperature:
            String(localized: "Before Temperature")
        case .afterTemperature:
            String(localized: "After Temperature")
        }
    }
}
