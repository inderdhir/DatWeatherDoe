//
//  TemperatureData.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/23/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import Foundation

struct TemperatureData: Decodable {
    let tempCelsius: Double
    let feelsLikeTempCelsius: Double
    let tempFahrenheit: Double
    let feelsLikeTempFahrenheit: Double

    private enum CodingKeys: String, CodingKey {
        case tempCelsius = "temp_c"
        case feelsLikeTempCelsius = "feelslike_c"
        case tempFahrenheit = "temp_f"
        case feelsLikeTempFahrenheit = "feelslike_f"
    }
}
