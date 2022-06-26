//
//  WeatherData.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/22/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

struct WeatherData {
    let showWeatherIcon: Bool
    let cityId: Int
    let textualRepresentation: String?
    let location: String?
    let temperatureData: WeatherAPIResponse.TemperatureData
    let weatherCondition: WeatherCondition
    let windData: WeatherAPIResponse.WindData
    let humidity: Int
}
