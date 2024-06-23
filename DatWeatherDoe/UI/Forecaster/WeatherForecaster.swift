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
    func seeForecastForCity()
}

final class WeatherForecaster: WeatherForecasterType {
    private let fullWeatherUrl = URL(string: "https://www.weatherapi.com/weather/")!

    func seeForecastForCity() {
        NSWorkspace.shared.open(fullWeatherUrl)
    }
}
