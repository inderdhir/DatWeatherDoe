//
//  TestData.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/25/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import Foundation

let response = WeatherAPIResponse(
    locationName: "New York City",
    temperatureData: .init(
        tempCelsius: 31.1,
        feelsLikeTempCelsius: 29.1,
        tempFahrenheit: 88.0,
        feelsLikeTempFahrenheit: 84.4
    ),
    isDay: true,
    weatherConditionCode: 1000,
    humidity: 45,
    windData: .init(speedMph: 12.3, degrees: 305, direction: "NW"),
    uvIndex: 7.0,
    forecastDayData: .init(
        temp: .init(
            maxTempC: 32.8, maxTempF: 91.0, minTempC: 20.6, minTempF: 69.2
        ),
        astro: .init(sunrise: "05:26 AM", sunset: "08:31 PM")
    ),
    airQualityIndex: .good
)
