//
//  WeatherResponse.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 2/3/18.
//  Copyright © 2018 Inder Dhir. All rights reserved.
//

import Cocoa

struct WeatherResponse: Decodable {

    static let temperatureFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .halfUp
        return formatter
    }()
    static let humidityFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    private let temperature: Double
    private let humidity: Int
    private let location: String
    private let weatherId: Int

    private enum RootKeys: String, CodingKey {
        case main, weather, name
    }

    private enum APIKeys: String, CodingKey {
        case temperature = "temp"
        case humidity
    }

    private enum WeatherKeys: String, CodingKey {
        case id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        temperature = try container.nestedContainer(keyedBy: APIKeys.self, forKey: .main)
            .decode(Double.self, forKey: .temperature)
        humidity = try container.nestedContainer(keyedBy: APIKeys.self, forKey: .main)
            .decode(Int.self, forKey: .humidity)
        location = try container.decode(String.self, forKey: .name)

        var weatherContainer = try container.nestedUnkeyedContainer(forKey: .weather)
        let weatherChildContainer = try weatherContainer.nestedContainer(keyedBy: WeatherKeys.self)
        weatherId = try weatherChildContainer.decode(Int.self, forKey: .id)
    }

    var icon: String? {
        switch weatherId {
        case 800:
            return WeatherConditions.sunny.rawValue
        case 801:
            return WeatherConditions.partlyCloudy.rawValue
        case 802...900:
            return WeatherConditions.cloudy.rawValue
        case 700..<800:
            return WeatherConditions.mist.rawValue
        case 600..<700:
            return WeatherConditions.snow.rawValue
        case 520..<600:
            return WeatherConditions.partlyCloudyRain.rawValue
        case 511:
            return WeatherConditions.freezingRain.rawValue
        case 500...504:
            return WeatherConditions.heavyRain.rawValue
        case 300..<500:
            return WeatherConditions.lightRain.rawValue
        case 200..<300:
            return WeatherConditions.thunderstorm.rawValue
        default:
            print("Unknown weather ID:", weatherId)
            break
        }
        return nil
    }

    var temperatureString: String? {
        let temperatureInUnits = DefaultsManager.shared.unit == .fahrenheit ?
            ((temperature - 273.15) * 1.8) + 32 : temperature - 273.15
        guard let formattedString = WeatherResponse.temperatureFormatter.string(from: NSNumber(value: temperatureInUnits)) else {
            fatalError("Unable to construct formatted temperature string")
        }
        return "\(formattedString)\u{00B0}"
    }

    var humidityString: String? {
        guard let formattedString = WeatherResponse.humidityFormatter.string(from: NSNumber(value: humidity)) else {
            fatalError("Unable to construct formatted humidity string")
        }
        return "\(formattedString)\u{0025}"
    }

    var locationString: String? { location }

    var weatherString: String? {
        let tempString = temperatureString ?? ""
        guard DefaultsManager.shared.showHumidity else {
            return tempString
        }

        let humString: String
        if let humidityString = humidityString {
            humString = "/\(humidityString)"
        } else {
            humString = ""
        }
        return "\(tempString)\(humString)"
    }
}
