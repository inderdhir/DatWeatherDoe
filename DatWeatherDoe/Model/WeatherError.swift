//
//  WeatherError.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/22/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import Foundation

enum WeatherError: Error {
    case unableToConstructUrl
    case zipCodeEmpty
    case latLongEmpty, latLongIncorrect
    case networkError
    case unableToParseWeatherResponse
    case unableToParseTemperatureUnit
    case other
}
