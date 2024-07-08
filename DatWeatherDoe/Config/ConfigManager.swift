//
//  ConfigManager.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/29/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Foundation
import SwiftUI

protocol ConfigManagerType: AnyObject {
    var measurementUnit: String { get set }
    var weatherSource: String { get set }
    var weatherSourceText: String { get set }
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

    var parsedMeasurementUnit: MeasurementUnit { get }
}

final class ConfigManager: ConfigManagerType {
    @AppStorage("measurementUnit")
    public var measurementUnit = MeasurementUnit.imperial.rawValue

    @AppStorage("weatherSource")
    public var weatherSource = WeatherSource.location.rawValue

    @AppStorage("weatherSourceText")
    public var weatherSourceText = ""

    @AppStorage("refreshInterval")
    public var refreshInterval = RefreshInterval.fifteenMinutes.rawValue

    @AppStorage("isShowingWeatherIcon")
    public var isShowingWeatherIcon = true

    @AppStorage("isShowingHumidity")
    public var isShowingHumidity = false

    @AppStorage("isRoundingOffData")
    public var isRoundingOffData = false

    @AppStorage("isUnitLetterOff")
    public var isUnitLetterOff = false

    @AppStorage("isUnitSymbolOff")
    public var isUnitSymbolOff = false

    @AppStorage("valueSeparator")
    public var valueSeparator = "\u{007C}"

    @AppStorage("isWeatherConditionAsTextEnabled")
    public var isWeatherConditionAsTextEnabled = false

    @AppStorage("weatherConditionPosition")
    public var weatherConditionPosition = WeatherConditionPosition.beforeTemperature.rawValue

    func updateWeatherSource(_ source: WeatherSource, sourceText: String) {
        weatherSource = source.rawValue
        weatherSourceText = source == .location ? "" : sourceText
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

    var parsedMeasurementUnit: MeasurementUnit {
        MeasurementUnit(rawValue: measurementUnit) ?? .imperial
    }
}
