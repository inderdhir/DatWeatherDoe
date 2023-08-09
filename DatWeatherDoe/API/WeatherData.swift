//
//  WeatherData.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/22/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import Foundation

struct WeatherData {
    let showWeatherIcon: Bool
    let textualRepresentation: String?
    let weatherCondition: WeatherCondition
    let response: WeatherAPIResponse
}
