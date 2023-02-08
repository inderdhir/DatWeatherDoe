//
//  WeatherAPIResponseParser.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/10/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class WeatherAPIResponseParser {

    func parse(_ data: Data) throws -> WeatherAPIResponse {
        try JSONDecoder().decode(WeatherAPIResponse.self, from: data)
    }
}
