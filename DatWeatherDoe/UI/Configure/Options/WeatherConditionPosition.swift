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
            return NSLocalizedString("Before Temperature", comment: "Weather condition before temperature")
        case .afterTemperature:
            return NSLocalizedString("After Temperature", comment: "Weather condition after temperature")
        }
    }
}
