//
//  MeasurementUnit.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 2/7/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

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

enum MeasurementUnit: String, CaseIterable, Identifiable {
    case metric, imperial
    
    var id: Self { self }
    
    var temperatureUnit: TemperatureUnit {
        switch self {
        case .metric:
            return .celsius
        case .imperial:
            return .fahrenheit
        }
    }
}
