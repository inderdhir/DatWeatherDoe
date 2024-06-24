//
//  WeatherViewModelType.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Combine

protocol WeatherViewModelType: AnyObject {
    func getUpdatedWeatherAfterRefresh()
    func seeForecastForCurrentCity()
}
