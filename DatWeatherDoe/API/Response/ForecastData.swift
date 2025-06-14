//
//  ForecastData.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/23/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import Foundation

struct Forecast: Decodable {
    let dayDataArr: [ForecastDayData]

    private enum CodingKeys: String, CodingKey {
        case dayDataArr = "forecastday"
    }
}

struct ForecastDayData: Decodable {
    let temp: ForecastTemperatureData
    let astro: SunriseSunsetData
    let hour: [HourlyUVIndex]

    private enum CodingKeys: String, CodingKey {
        case temp = "day"
        case astro
        case hour
    }
}

struct HourlyUVIndex: Decodable {
    // swiftlint:disable:next identifier_name
    let uv: Double
}
