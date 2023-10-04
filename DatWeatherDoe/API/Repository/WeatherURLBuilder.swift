//
//  WeatherURLBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/10/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation
import Foundation

protocol WeatherURLBuilderType {
    func build(unit: MeasurementUnit) throws -> URL
}

class WeatherURLBuilder: WeatherURLBuilderType {
    
    let apiUrlString = "https://api.openweathermap.org/data/2.5/weather"
    let appId: String
    
    init(appId: String) {
        self.appId = appId
    }
    
    func build(unit: MeasurementUnit) throws -> URL { URL(string: apiUrlString)! }
}
