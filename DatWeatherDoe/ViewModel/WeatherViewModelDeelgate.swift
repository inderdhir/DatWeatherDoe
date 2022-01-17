//
//  WeatherViewModelDeelgate.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/16/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

protocol WeatherViewModelDelegate: AnyObject {
    func didUpdateWeatherData(_ data: WeatherData)
    func didFailToUpdateWeatherData(_ error: String)
}
