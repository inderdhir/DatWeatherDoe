//
//  WeatherForecaster.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Cocoa
import Foundation

final class WeatherForecaster {
    
    private let fullWeatherUrl = URL(string: "https://openweathermap.org/city")!
    private var cityId = 0

    func updateCity(cityId: Int) {
        self.cityId = cityId
    }
    
    func seeForecastForCity() {
        let cityWeatherUrl = fullWeatherUrl.appendingPathComponent(String(cityId))
        NSWorkspace.shared.open(cityWeatherUrl)
    }
}
