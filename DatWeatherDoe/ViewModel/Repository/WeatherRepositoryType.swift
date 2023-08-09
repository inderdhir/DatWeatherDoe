////
////  WeatherRepositoryType.swift
////  DatWeatherDoe
////
////  Created by Inder Dhir on 1/30/16.
////  Copyright © 2016 Inder Dhir. All rights reserved.
////

protocol WeatherRepositoryType: AnyObject {
    func getWeather(unit: MeasurementUnit) async throws -> WeatherAPIResponse
}
