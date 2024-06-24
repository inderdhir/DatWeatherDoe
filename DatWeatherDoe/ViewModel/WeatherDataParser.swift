//
//  WeatherDataParser.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/24/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import Foundation

final class WeatherDataParser {
    let data: WeatherData
    let configManager: ConfigManagerType
    
    init(data: WeatherData, configManager: ConfigManagerType) {
        self.data = data
        self.configManager = configManager
    }
    
    func getLocation() -> String {
        [
            data.response.locationName,
            WeatherConditionTextMapper().map(data.weatherCondition)
        ]
            .joined(separator: " - ")
    }
    
    func getWeatherText() -> String {
        let measurementUnit = MeasurementUnit(rawValue: configManager.measurementUnit) ?? .imperial
        
        return TemperatureForecastTextBuilder(
            temperatureData: data.response.temperatureData,
            forecastTemperatureData: data.response.forecastDayData.temp,
            options: .init(
                unit: measurementUnit.temperatureUnit,
                isRoundingOff: configManager.isRoundingOffData,
                isUnitLetterOff: configManager.isUnitLetterOff,
                isUnitSymbolOff: configManager.isUnitSymbolOff
            )
        ).build()
    }
    
    func getSunriseSunset() -> String {
        SunriseAndSunsetTextBuilder(
            sunset: data.response.forecastDayData.astro.sunset,
            sunrise: data.response.forecastDayData.astro.sunrise
        ).build()
    }
    
    func getWindSpeedItem() -> String {
        if configManager.measurementUnit == MeasurementUnit.all.rawValue {
            WindSpeedFormatter()
                .getFormattedWindSpeedStringForAllUnits(
                    windData: data.response.windData,
                    isRoundingOff: configManager.isRoundingOffData
                )
        } else {
            WindSpeedFormatter()
                .getFormattedWindSpeedString(
                    unit: MeasurementUnit(rawValue: configManager.measurementUnit) ?? .imperial,
                    windData: data.response.windData
                )
        }
    }
}
