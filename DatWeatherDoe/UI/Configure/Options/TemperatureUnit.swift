//
//  TemperatureUnit.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 8/8/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation

enum TemperatureUnit: String, CaseIterable, Identifiable {
    case fahrenheit, celsius, all

    var id: Self { self }

    var unitString: String {
        switch self {
        case .fahrenheit:
            return "F"
        case .celsius:
            return "C"
        case .all:
            return "All"
        }
    }

    var degreesString: String {
        "\u{00B0}\(unitString)"
    }
}
