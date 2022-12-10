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
    case zipCodeIncorrect
    case latLongIncorrect
    case locationError
    case networkError
    case unableToParseWeatherResponse
    case unableToParseTemperatureUnit
    case other
}
