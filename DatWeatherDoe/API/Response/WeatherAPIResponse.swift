//
//  WeatherResponse.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 2/3/18.
//  Copyright © 2018 Inder Dhir. All rights reserved.
//

import Foundation

struct WeatherAPIResponse: Decodable {
    let cityId: Int
    let temperatureData: TemperatureData
    let humidity: Int
    let location: String
    let weatherId: Int
    let sunrise: TimeInterval
    let sunset: TimeInterval
    let windData: WindData
    
    struct TemperatureData: Decodable {
        let temperature: Double
        let feelsLikeTemperature: Double
        let minTemperature: Double
        let maxTemperature: Double
        
        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case temperature = "temp"
            case feelsLikeTemperature = "feels_like"
            case minTemperature = "temp_min"
            case maxTemperature = "temp_max"
        }
    }
    
    struct WindData: Decodable {
        let speed: Double
        let degrees: Int
        
        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case speed
            case degrees = "deg"
        }
    }
    
    private enum RootKeys: String, CodingKey {
        case cityId = "id"
        case main, weather, humidity, name, sys, wind
    }
    
    private enum MainKeys: String, CodingKey {
        case humidity
    }
    
    private enum SysKeys: String, CodingKey {
        case sunrise, sunset
    }
    
    private enum WeatherKeys: String, CodingKey {
        case id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        cityId = try container.decode(Int.self, forKey: .cityId)
        temperatureData = try container.decode(TemperatureData.self, forKey: .main)

        let mainContainer = try container.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
        humidity = try mainContainer.decode(Int.self, forKey: .humidity)

        location = try container.decode(String.self, forKey: .name)

        var weatherContainer = try container.nestedUnkeyedContainer(forKey: .weather)
        let weatherChildContainer = try weatherContainer.nestedContainer(keyedBy: WeatherKeys.self)
        weatherId = try weatherChildContainer.decode(Int.self, forKey: .id)

        let sysContainer = try container.nestedContainer(keyedBy: SysKeys.self, forKey: .sys)
        sunrise = try sysContainer.decode(TimeInterval.self, forKey: .sunrise)
        sunset = try sysContainer.decode(TimeInterval.self, forKey: .sunset)
        
        windData = try container.decode(WindData.self, forKey: .wind)
    }
}
