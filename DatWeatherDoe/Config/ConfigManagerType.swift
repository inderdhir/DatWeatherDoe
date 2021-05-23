//
//  ConfigManagerType.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/22/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import Foundation

protocol ConfigManagerType: AnyObject {
    var temperatureUnit: String { get set }
    var weatherSource: String { get set }
    var weatherSourceText: String? { get set }
    var refreshInterval: TimeInterval { get set }
    var isShowingHumidity: Bool { get set }
    var isRoundingOffData: Bool { get set }
}
