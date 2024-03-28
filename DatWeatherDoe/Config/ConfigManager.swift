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
    var weatherConditionPosition: String { get set }

    func updateWeatherSource(_ source: WeatherSource, sourceText: String)
    func setConfigOptions(_ options: ConfigOptions)
}

final class ConfigManager: ConfigManagerType {
    @Storage(key: "measurementUnit", defaultValue: MeasurementUnit.imperial.rawValue)
    public var measurementUnit: String

    @Storage(key: "weatherSource", defaultValue: WeatherSource.location.rawValue)
    public var weatherSource: String

    @Storage(key: "weatherSourceText", defaultValue: nil)
    public var weatherSourceText: String?

    @Storage(key: "refreshInterval", defaultValue: RefreshInterval.fifteenMinutes.rawValue)
    public var refreshInterval: TimeInterval

    @Storage(key: "isShowingWeatherIcon", defaultValue: true)
    public var isShowingWeatherIcon: Bool

    @Storage(key: "isShowingHumidity", defaultValue: false)
    public var isShowingHumidity: Bool

    @Storage(key: "isRoundingOffData", defaultValue: false)
    public var isRoundingOffData: Bool

    @Storage(key: "isUnitLetterOff", defaultValue: false)
    public var isUnitLetterOff: Bool

    @Storage(key: "isUnitSymbolOff", defaultValue: false)
    public var isUnitSymbolOff: Bool

    @Storage(key: "valueSeparator", defaultValue: "\u{007C}")
    public var valueSeparator: String

    @Storage(key: "isWeatherConditionAsTextEnabled", defaultValue: false)
    public var isWeatherConditionAsTextEnabled: Bool
    
    @Storage(
        key: "weatherConditionPosition",
        defaultValue: WeatherConditionPosition.beforeTemperature.rawValue
    )
    public var weatherConditionPosition: String

    func updateWeatherSource(_ source: WeatherSource, sourceText: String) {
        weatherSource = source.rawValue
        weatherSourceText = source == .location ? nil : sourceText
    }

    func setConfigOptions(_ options: ConfigOptions) {
        refreshInterval = options.refreshInterval.rawValue
        isShowingHumidity = options.isShowingHumidity
        isRoundingOffData = options.isRoundingOffData
        isUnitLetterOff = options.isUnitLetterOff
        isUnitSymbolOff = options.isUnitSymbolOff
        valueSeparator = options.valueSeparator
        isWeatherConditionAsTextEnabled = options.isWeatherConditionAsTextEnabled
    }
}
