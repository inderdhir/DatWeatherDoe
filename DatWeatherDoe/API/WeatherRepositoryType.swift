//
//  WeatherRepositoryType.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/22/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import CoreLocation

protocol WeatherRepositoryType: AnyObject {
    func getWeather(
        zipCode: String,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    )
    func getWeather(
        latLong: String,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    )
    func getWeather(
        location: CLLocationCoordinate2D,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    )
}
