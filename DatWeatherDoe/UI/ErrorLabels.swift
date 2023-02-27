//
//  ErrorLabels.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class ErrorLabels {
    lazy var networkErrorString =
    NSLocalizedString("Network Error", comment: "Network error when fetching weather")
    lazy var locationErrorString =
    NSLocalizedString("Location Error", comment: "Location error when fetching weather")
    lazy var latLongErrorString =
    NSLocalizedString("Lat/Long Error", comment: "Lat/Long error when fetching weather")
    lazy var zipCodeErrorString =
    NSLocalizedString("Zip Code Error", comment: "Zip Code error when fetching weather")
    lazy var cityErrorString =
    NSLocalizedString("City Error", comment: "City error when fetching weather")
}
