//
//  WeatherResponse.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 2/3/18.
//  Copyright © 2018 Inder Dhir. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults

struct WeatherResponse: Decodable {

    private static let temperatureFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    let temperature: Double
    let weatherId: Int

    enum RootKeys: String, CodingKey {
        case main, weather
    }

    enum TemperatureKeys: String, CodingKey {
        case temperature = "temp"
    }

    enum WeatherKeys: String, CodingKey {
        case id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        temperature = try container.nestedContainer(
            keyedBy: TemperatureKeys.self, forKey: .main)
            .decode(Double.self, forKey: .temperature)

        var weatherContainer = try container.nestedUnkeyedContainer(forKey: .weather)
        let weatherChildContainer = try weatherContainer.nestedContainer(keyedBy: WeatherKeys.self)
        weatherId = try weatherChildContainer.decode(Int.self, forKey: .id)
    }

    var icon: String? {
        let darkModeOn =
            ((UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light") == "Dark")

        switch weatherId {
        case 800:
            return darkModeOn ?
                WeatherConditions.sunnyDark.rawValue : WeatherConditions.sunny.rawValue
        case 801:
            return darkModeOn ?
                WeatherConditions.partlyCloudyDark.rawValue :
                WeatherConditions.partlyCloudy.rawValue
        case 802...900:
            return darkModeOn ?
                WeatherConditions.cloudyDark.rawValue : WeatherConditions.cloudy.rawValue
        case 700..<800:
            return darkModeOn ?
                WeatherConditions.mistDark.rawValue : WeatherConditions.mist.rawValue
        case 600..<700:
            return darkModeOn ?
                WeatherConditions.snowDark.rawValue : WeatherConditions.snow.rawValue
        case 520..<600:
            return darkModeOn ?
                WeatherConditions.partlyCloudyRainDark.rawValue :
                WeatherConditions.partlyCloudyRain.rawValue
        case 511:
            return darkModeOn ?
                WeatherConditions.freezingRainDark.rawValue :
                WeatherConditions.freezingRain.rawValue
        case 500...504:
            return darkModeOn ?
                WeatherConditions.heavyRainDark.rawValue :
                WeatherConditions.heavyRain.rawValue
        case 300..<500:
            return darkModeOn ?
                WeatherConditions.lightRainDark.rawValue : WeatherConditions.lightRain.rawValue
        case 200..<300:
            return darkModeOn ?
                WeatherConditions.thunderstormDark.rawValue :
                WeatherConditions.thunderstorm.rawValue
        default:
            break
        }
        return nil
    }

    var temperatureString: String? {
        let doubleTemp = (temperature as NSNumber).doubleValue
        let temperatureInUnits =
            Defaults[.unit] == TemperatureUnit.fahrenheit.rawValue ?
                ((doubleTemp - 273.15) * 1.8) + 32 : doubleTemp - 273.15
        return WeatherResponse.temperatureFormatter.string(
            from: NSNumber(value: temperatureInUnits))! + "\u{00B0}"
    }
}
