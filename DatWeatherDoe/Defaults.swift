//
//  Defaults.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/29/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Foundation

class DefaultsManager {

    public static let shared = DefaultsManager()

    private enum DefaultsKeys: String {
        case zipCode, refreshInterval, unit, usingLocation
    }

    public var zipCode: String {
        get {
            if let zipCode = UserDefaults.standard.string(forKey: DefaultsKeys.zipCode.rawValue),
                !zipCode.isEmpty {
                return zipCode
            }
            return "10021,us"
        }
        set { UserDefaults.standard.set(newValue, forKey: DefaultsKeys.zipCode.rawValue) }
    }

    public var refreshInterval: TimeInterval {
        get {
            var interval = UserDefaults.standard.double(forKey: DefaultsKeys.refreshInterval.rawValue)
            if interval == 0 { interval = 60 }
            return interval
        }
        set { UserDefaults.standard.set(newValue, forKey: DefaultsKeys.refreshInterval.rawValue) }
    }

    public var unit: TemperatureUnit {
        get {
            if let temperatureString = UserDefaults.standard.string(forKey: DefaultsKeys.unit.rawValue) {
                return TemperatureUnit(rawValue: temperatureString) ?? .fahrenheit
            }
            return .fahrenheit
        }
        set { UserDefaults.standard.setValue(newValue.rawValue, forKey: DefaultsKeys.unit.rawValue) }
    }

    public var usingLocation: Bool {
        get { return UserDefaults.standard.bool(forKey: DefaultsKeys.usingLocation.rawValue) }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.usingLocation.rawValue) }
    }
}
