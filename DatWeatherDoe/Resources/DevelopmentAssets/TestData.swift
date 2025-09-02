//
//  TestData.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/25/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import Foundation

let uvIndicesFor24Hours: [HourlyUVIndex] = {
    var arr: [HourlyUVIndex] = []
    // swiftlint:disable:next identifier_name
    for i in 1 ... 24 {
        arr.append(HourlyUVIndex(uv: 0))
    }
    return arr
}()

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
        temperatureData: .init(
            maxTempC: 32.8, maxTempF: 91.0, minTempC: 20.6, minTempF: 69.2
        ),
        astro: .init(sunrise: "05:26 AM", sunset: "08:31 PM"),
        hour: uvIndicesFor24Hours
    ),
    airQualityIndex: .good
)
