//
//  WeatherAPIResponse.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 2/3/18.
//  Copyright © 2018 Inder Dhir. All rights reserved.
//

import Foundation

struct WeatherAPIResponse: Decodable {
    let locationName: String
    let temperatureData: TemperatureData
    let weatherConditionCode: Int
    let humidity: Int
    let windData: WindData
    let forecastDayData: ForecastDayData

    private enum RootKeys: String, CodingKey {
        case location, current, forecast
    }

    private enum LocationKeys: String, CodingKey {
        case name
    }

    private enum CurrentKeys: String, CodingKey {
        case condition, humidity
    }

    private enum WeatherConditionKeys: String, CodingKey {
        case code
    }

    private enum ForecastKeys: String, CodingKey {
        case forecastDay = "forecastday"
    }

    private enum ForecastDayKeys: String, CodingKey {
        case day, astro
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)

        let locationContainer = try container.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        locationName = try locationContainer.decode(String.self, forKey: .name)
        temperatureData = try container.decode(TemperatureData.self, forKey: .current)

        let currentContainer = try container.nestedContainer(keyedBy: CurrentKeys.self, forKey: .current)
        let weatherConditionContainer = try currentContainer.nestedContainer(
            keyedBy: WeatherConditionKeys.self,
            forKey: .condition
        )
        weatherConditionCode = try weatherConditionContainer.decode(Int.self, forKey: .code)

        windData = try container.decode(WindData.self, forKey: .current)

        humidity = try currentContainer.decode(Int.self, forKey: .humidity)

        let forecast = try container.decode(Forecast.self, forKey: .forecast)
        if let dayData = forecast.dayDataArr.first {
            forecastDayData = dayData
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .forecast,
                in: container,
                debugDescription: "Missing forecast day data"
            )
        }
    }
}
