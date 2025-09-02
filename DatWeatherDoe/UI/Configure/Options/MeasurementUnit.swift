//
//  MeasurementUnit.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 2/7/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation

enum MeasurementUnit: String, CaseIterable, Identifiable {
    case metric, imperial, all

    var id: Self { self }

    var temperatureUnit: TemperatureUnit {
        switch self {
        case .metric:
            .celsius
        case .imperial:
            .fahrenheit
        case .all:
            .all
        }
    }
}
