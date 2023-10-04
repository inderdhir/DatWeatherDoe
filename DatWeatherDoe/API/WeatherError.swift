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
    case cityIncorrect
    case latLongIncorrect
    case locationError
    case networkError
}
