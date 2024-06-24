//
//  SunriseSunsetData.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/22/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import Foundation

struct SunriseSunsetData: Decodable {
    let sunrise: String
    let sunset: String

    private enum CodingKeys: String, CodingKey {
        case sunrise, sunset
    }
}
