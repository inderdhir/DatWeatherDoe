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

    private enum CodingKeys: String, CodingKey {
        case temp = "day"
        case astro
    }
}
