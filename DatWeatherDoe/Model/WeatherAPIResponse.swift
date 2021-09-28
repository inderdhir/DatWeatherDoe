//
//  WeatherResponse.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 2/3/18.
//  Copyright © 2018 Inder Dhir. All rights reserved.
//

import Foundation

struct WeatherAPIResponse: Decodable {

    let temperature: Double
    let humidity: Int
    let location: String
    let weatherId: Int
    let sunsetTime: TimeInterval

    private enum RootKeys: String, CodingKey {
        case main, weather, name, sys
    }
    private enum APIKeys: String, CodingKey {
        case temperature = "temp"
        case humidity
        case sunset
    }
    private enum WeatherKeys: String, CodingKey {
        case id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)

        let mainContainer = try container.nestedContainer(keyedBy: APIKeys.self, forKey: .main)
        temperature = try mainContainer.decode(Double.self, forKey: .temperature)
        humidity = try mainContainer.decode(Int.self, forKey: .humidity)

        location = try container.decode(String.self, forKey: .name)

        var weatherContainer = try container.nestedUnkeyedContainer(forKey: .weather)
        let weatherChildContainer = try weatherContainer.nestedContainer(keyedBy: WeatherKeys.self)
        weatherId = try weatherChildContainer.decode(Int.self, forKey: .id)

        let sysContainer = try container.nestedContainer(keyedBy: APIKeys.self, forKey: .sys)
        sunsetTime = try sysContainer.decode(TimeInterval.self, forKey: .sunset)
    }
}
