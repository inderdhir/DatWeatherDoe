//
//  ConfigManager.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/29/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Foundation

protocol ConfigManagerType: AnyObject {
    var measurementUnit: String { get set }
    var weatherSource: String { get set }
    var weatherSourceText: String? { get set }
    var refreshInterval: TimeInterval { get set }
    var isShowingWeatherIcon: Bool { get set }
    var isShowingHumidity: Bool { get set }
    var isRoundingOffData: Bool { get set }
    var isUnitLetterOff: Bool { get set }
    var isUnitSymbolOff: Bool { get set }
    var valueSeparator: String { get set }
    var isWeatherConditionAsTextEnabled: Bool { get set }
}

final class ConfigManager: ConfigManagerType {

    private enum DefaultsKeys: String {
        case measurementUnit
        case weatherSource
        case weatherSourceText
        case refreshInterval
        case isShowingWeatherIcon
        case isShowingHumidity
        case isRoundingOffData
        case isUnitLetterOff
        case isUnitSymbolOff
        case valueSeparator
        case isWeatherConditionAsTextEnabled
    }

    @Storage(
        key: DefaultsKeys.measurementUnit.rawValue,
        defaultValue: MeasurementUnit.imperial.rawValue
    )
    public var measurementUnit: String

    @Storage(
        key: DefaultsKeys.weatherSource.rawValue,
        defaultValue: WeatherSource.location.rawValue
    )
    public var weatherSource: String

    @Storage(key: DefaultsKeys.weatherSourceText.rawValue, defaultValue: nil)
    public var weatherSourceText: String?

    @Storage(
        key: DefaultsKeys.refreshInterval.rawValue,
        defaultValue: RefreshInterval.fifteenMinutes.rawValue
    )
    public var refreshInterval: TimeInterval
    
    @Storage(key: DefaultsKeys.isShowingWeatherIcon.rawValue, defaultValue: true)
    public var isShowingWeatherIcon: Bool

    @Storage(key: DefaultsKeys.isShowingHumidity.rawValue, defaultValue: false)
    public var isShowingHumidity: Bool

    @Storage(key: DefaultsKeys.isRoundingOffData.rawValue, defaultValue: false)
    public var isRoundingOffData: Bool

    @Storage(key: DefaultsKeys.isUnitLetterOff.rawValue, defaultValue: false)
    public var isUnitLetterOff: Bool

    @Storage(key: DefaultsKeys.isUnitSymbolOff.rawValue, defaultValue: false)
    public var isUnitSymbolOff: Bool

    @Storage(key: DefaultsKeys.valueSeparator.rawValue, defaultValue: " \u{007C} ")
    public var valueSeparator: String

    @Storage(
        key: DefaultsKeys.isWeatherConditionAsTextEnabled.rawValue,
        defaultValue: false
    )
    public var isWeatherConditionAsTextEnabled: Bool
}
