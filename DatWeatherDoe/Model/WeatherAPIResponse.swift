//
//  WeatherResponse.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 2/3/18.
//  Copyright © 2018 Inder Dhir. All rights reserved.
//

struct WeatherAPIResponse: Decodable {

    let temperature: Double
    let humidity: Int
    let location: String
    let weatherId: Int

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
}
