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
    let isDay: Bool
    let weatherConditionCode: Int
    let humidity: Int
    let windData: WindData
    let uvIndex: Double
    let forecastDayData: ForecastDayData
    let airQualityIndex: AirQualityIndex

    private enum RootKeys: String, CodingKey {
        case location, current, forecast
    }

    private enum LocationKeys: String, CodingKey {
        case name
    }

    private enum CurrentKeys: String, CodingKey {
        case isDay = "is_day"
        case condition, humidity
        case airQuality = "air_quality"
        case uvIndex = "uv"
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

    private enum AirQualityKeys: String, CodingKey {
        case usEpaIndex = "us-epa-index"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)

        let locationContainer = try container.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
        locationName = try locationContainer.decode(String.self, forKey: .name)
        temperatureData = try container.decode(TemperatureData.self, forKey: .current)

        let currentContainer = try container.nestedContainer(keyedBy: CurrentKeys.self, forKey: .current)
        let isDayInt = try currentContainer.decode(Int.self, forKey: .isDay)
        isDay = isDayInt > 0

        let weatherConditionContainer = try currentContainer.nestedContainer(
            keyedBy: WeatherConditionKeys.self,
            forKey: .condition
        )
        weatherConditionCode = try weatherConditionContainer.decode(Int.self, forKey: .code)

        humidity = try currentContainer.decode(Int.self, forKey: .humidity)

        windData = try container.decode(WindData.self, forKey: .current)

        uvIndex = try currentContainer.decode(Double.self, forKey: .uvIndex)

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

        let airQualityContainer = try currentContainer.nestedContainer(keyedBy: AirQualityKeys.self, forKey: .airQuality)
        airQualityIndex = try airQualityContainer.decode(AirQualityIndex.self, forKey: .usEpaIndex)
    }

    init(
        locationName: String,
        temperatureData: TemperatureData,
        isDay: Bool,
        weatherConditionCode: Int,
        humidity: Int,
        windData: WindData,
        uvIndex: Double,
        forecastDayData: ForecastDayData,
        airQualityIndex: AirQualityIndex
    ) {
        self.locationName = locationName
        self.temperatureData = temperatureData
        self.isDay = isDay
        self.weatherConditionCode = weatherConditionCode
        self.humidity = humidity
        self.windData = windData
        self.uvIndex = uvIndex
        self.forecastDayData = forecastDayData
        self.airQualityIndex = airQualityIndex
    }
}
