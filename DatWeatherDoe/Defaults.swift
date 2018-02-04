//
//  Defaults.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/29/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import SwiftyUserDefaults

public extension DefaultsKeys {
    static let zipCode = DefaultsKey<String>("zipCode")
    static let refreshInterval = DefaultsKey<TimeInterval>("refreshInterval")
    static let unit = DefaultsKey<String>("unit")
    static let usingLocation = DefaultsKey<Bool>("location")
}

extension UserDefaults {

    subscript(key: DefaultsKey<String>) -> String {
        get {
            if let existingValue = unarchive(key) {
                return existingValue
            }

            switch key._key {
            case "zipCode":
                return "10021,us"
            case "unit":
                return TemperatureUnit.fahrenheit.rawValue
            default:
                return ""
            }
        }
        set { archive(key, newValue) }
    }

    subscript(key: DefaultsKey<TimeInterval>) -> TimeInterval {
        get { return unarchive(key) ?? 60 }
        set { archive(key, newValue) }
    }
}
