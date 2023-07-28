//
//  ErrorLabels.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class ErrorLabels {
    lazy var networkErrorString = "🖧" // "Network error when fetching weather"
    lazy var locationErrorString =
    NSLocalizedString("❗️Location ", comment: "Location error when fetching weather")
    lazy var latLongErrorString =
    NSLocalizedString("❗️Lat/Long ", comment: "Lat/Long error when fetching weather")
    lazy var cityErrorString =
    NSLocalizedString("❗️City ", comment: "City error when fetching weather")
}
