//
//  TemperatureUnit.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/22/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
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
