//
//  WeatherViewModelType.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

protocol WeatherViewModelType: AnyObject {
    var delegate: WeatherViewModelDelegate? { get set }
    func getUpdatedWeather()
}
