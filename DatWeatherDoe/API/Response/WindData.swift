//
//  WindData.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/23/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import Foundation

struct WindData: Decodable {
    let speedMph: Double
    let degrees: Int
    let direction: String

    private enum CodingKeys: String, CodingKey {
        case speedMph = "wind_mph"
        case degrees = "wind_degree"
        case direction = "wind_dir"
    }
}
