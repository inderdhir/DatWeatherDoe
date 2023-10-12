//
//  WeatherAPIResponseParser.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/10/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

protocol WeatherAPIResponseParserType {
    func parse(_ data: Data) throws -> WeatherAPIResponse
}

final class WeatherAPIResponseParser: WeatherAPIResponseParserType {
    func parse(_ data: Data) throws -> WeatherAPIResponse {
        try JSONDecoder().decode(WeatherAPIResponse.self, from: data)
    }
}
