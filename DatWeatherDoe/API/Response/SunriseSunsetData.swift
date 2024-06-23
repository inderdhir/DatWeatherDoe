//
//  SunriseSunsetData.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/22/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import Foundation

struct SunriseSunsetData: Decodable {
    let isDay: Int
    let sunrise: String
    let sunset: String

    private enum CodingKeys: String, CodingKey {
        case isDay = "is_sun_up"
        case sunrise, sunset
    }

    var isDayBool: Bool {
        isDay > 0
    }
}
