//
//  WeatherViewModelType.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Combine

protocol WeatherViewModelType: AnyObject {
    var weatherResult: AnyPublisher<Result<WeatherData, Error>, Never> { get }

    func startRefreshingWeather()
    func seeForecastForCurrentCity()
}
