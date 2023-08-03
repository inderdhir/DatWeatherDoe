//
//  ConfigOptions.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 8/3/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation

struct ConfigOptions {
    let refreshInterval: RefreshInterval
    let isShowingHumidity: Bool
    let isRoundingOffData: Bool
    let isUnitLetterOff: Bool
    let isUnitSymbolOff: Bool
    let valueSeparator: String
    let isWeatherConditionAsTextEnabled: Bool
}
