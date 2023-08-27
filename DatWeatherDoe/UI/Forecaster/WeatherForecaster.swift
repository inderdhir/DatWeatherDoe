//
//  WeatherForecaster.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Cocoa
import Foundation

protocol WeatherForecasterType {
    func updateCityWith(cityId: Int)
    func seeForecastForCity()
}

final class WeatherForecaster: WeatherForecasterType {
    
    private let fullWeatherUrl = URL(string: "https://openweathermap.org/city")!
    private var cityId = 0

    func updateCityWith(cityId: Int) {
        self.cityId = cityId
    }
    
    func seeForecastForCity() {
        let cityWeatherUrl = fullWeatherUrl.appendingPathComponent(String(cityId))
        NSWorkspace.shared.open(cityWeatherUrl)
    }
}
