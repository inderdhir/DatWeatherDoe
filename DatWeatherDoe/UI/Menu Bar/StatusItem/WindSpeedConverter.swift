//
//  WindSpeedConverter.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 10/12/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation

final class WindSpeedConverter {
    func convertToMilesPerHour(windInMeterPerSec: Double) -> Double {
        2.236 * windInMeterPerSec
    }
}
