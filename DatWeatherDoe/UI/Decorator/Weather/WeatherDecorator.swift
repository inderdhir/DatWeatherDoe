//
//  WeatherRepresentation.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/22/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import Foundation
import os

final class WeatherDecorator: WeatherDecoratorType {
    
    private let percentString = "\u{0025}"
    private let logger: DatWeatherDoeLoggerType
    private let response: WeatherAPIResponse
    private let options: WeatherDecoratorOptions
    
    init(
        logger: DatWeatherDoeLoggerType,
        response: WeatherAPIResponse,
        options: WeatherDecoratorOptions
    ) {
        self.logger = logger
        self.response = response
        self.options = options
    }
    
    func textualRepresentation(
        sunrise: TimeInterval,
        sunset: TimeInterval
    ) -> String {
        let weatherConditionAsText: String?
        if options.isWeatherConditionAsTextEnabled {
            let weatherCondition = weatherCondition(sunrise: sunrise, sunset: sunset)
            weatherConditionAsText = WeatherConditionTextMapper().mapConditionToText(weatherCondition)
        } else {
            weatherConditionAsText = nil
        }
        
        let weatherConditionAndTempStr = appendTemperaturetoWeatherCondition(
            weatherCondition: weatherConditionAsText
        )
        
        if options.isShowingHumidity {
            return constructWeatherWithHumidityString(weather: weatherConditionAndTempStr)
        } else {
            return weatherConditionAndTempStr
        }
    }
    
    func weatherCondition(
        sunrise: TimeInterval,
        sunset: TimeInterval
    ) -> WeatherCondition {
        WeatherConditionDecorator(
            sunrise: sunrise,
            sunset: sunset,
            weatherId: response.weatherId
        ).decorate()
    }
    
    private func appendTemperaturetoWeatherCondition(weatherCondition: String?) -> String {
        [weatherCondition, temperature]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
    
    private func constructWeatherWithHumidityString(weather: String) -> String {
        guard let humidity = humidity else { return weather }
        
        return "\(weather) | \(humidity)"
    }
    
    private var temperature: String? {
        TemperatureDecorator(
            options: options.buildTemperatureDecoratorOptions(
                temperature: response.temperature
            ),
            logger: logger
        ).decorate()
    }
    
    private var humidity: String? {
        guard let formattedString =
                WeatherFormatter.humidityFormatter.string(from: NSNumber(value: response.humidity)) else {
                    logger.error("Unable to construct formatted humidity string")
                    
                    return nil
                }
        
        return "\(formattedString)\(percentString)"
    }
}
