//
//  ConfigManager.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/29/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Foundation

final class ConfigManager: ConfigManagerType {

    private enum DefaultsKeys: String {
        case temperatureUnit
        case weatherSource
        case weatherSourceText
        case refreshInterval
        case isShowingHumidity
        case isRoundingOffData
    }

    @Storage(key: DefaultsKeys.temperatureUnit.rawValue, defaultValue: TemperatureUnit.fahrenheit.rawValue)
    public var temperatureUnit: String

    @Storage(key: DefaultsKeys.weatherSource.rawValue, defaultValue: WeatherSource.location.rawValue)
    public var weatherSource: String

    @Storage(key: DefaultsKeys.weatherSourceText.rawValue, defaultValue: nil)
    public var weatherSourceText: String?

    @Storage(key: DefaultsKeys.refreshInterval.rawValue, defaultValue: RefreshInterval.fifteenMinutes.rawValue)
    public var refreshInterval: TimeInterval

    @Storage(key: DefaultsKeys.isShowingHumidity.rawValue, defaultValue: false)
    public var isShowingHumidity: Bool

    @Storage(key: DefaultsKeys.isRoundingOffData.rawValue, defaultValue: false)
    public var isRoundingOffData: Bool
}
