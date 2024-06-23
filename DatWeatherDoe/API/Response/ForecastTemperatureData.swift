//
//  ForecastTemperatureData.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/23/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import Foundation

struct ForecastTemperatureData: Decodable {
    let maxTempC: Double
    let maxTempF: Double
    let minTempC: Double
    let minTempF: Double

    private enum CodingKeys: String, CodingKey {
        case maxTempC = "maxtemp_c"
        case maxTempF = "maxtemp_f"
        case minTempC = "mintemp_c"
        case minTempF = "mintemp_f"
    }
}
