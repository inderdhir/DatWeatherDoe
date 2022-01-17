//
//  Date+Night.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

extension Date {
    func isNight(sunrise: TimeInterval, sunset: TimeInterval) -> Bool {
        timeIntervalSince1970 >= sunset || timeIntervalSince1970 <= sunrise
    }
}
