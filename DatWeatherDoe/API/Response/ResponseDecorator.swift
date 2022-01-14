//
//  ResponseDecorator.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/10/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

final class ResponseDecorator {
    
    struct Options {
        let temperatureUnit: TemperatureUnit
        let isWeatherConditionAsTextEnabled: Bool
        let isShowingHumidity: Bool
        let isRoundingOff: Bool
    }
        
    private let options: Options
    private let logger: DatWeatherDoeLoggerType
    
    init(
        options: Options,
        logger: DatWeatherDoeLoggerType
    ) {
        self.options = options
        self.logger = logger
    }
    
    func getWeatherData(
        response: WeatherAPIResponse,
        temperatureUnit: TemperatureUnit
    ) -> WeatherData {
        let decorator = constructDecorator(
            response: response,
            temperatureUnit: temperatureUnit
        )
        return .init(
            cityId: response.cityId,
            textualRepresentation: getTextualRepresentation(
                decorator: decorator,
                response: response
            ),
            location: response.location,
            weatherCondition: getWeatherCondition(
                decorator: decorator,
                response: response
            )
        )
    }
    
    private func constructDecorator(
        response: WeatherAPIResponse,
        temperatureUnit: TemperatureUnit
    ) -> WeatherDecorator {
        let decoratorOptions = constructDecoratorOptions()
        let decorator = WeatherDecorator(
            logger: logger,
            response: response,
            options: decoratorOptions
        )
        return decorator
    }
    
    private func constructDecoratorOptions()
    -> WeatherDecoratorOptions {
        .init(
            temperatureUnit: options.temperatureUnit,
            isWeatherConditionAsTextEnabled: options.isWeatherConditionAsTextEnabled,
            isShowingHumidity: options.isShowingHumidity,
            isRoundingOff: options.isRoundingOff
        )
    }
    
    private func getTextualRepresentation(
        decorator: WeatherDecorator,
        response: WeatherAPIResponse
    ) -> String {
        decorator.textualRepresentation(
            sunrise: response.sunrise,
            sunset: response.sunset
        )
    }
    
    private func getWeatherCondition(
        decorator: WeatherDecorator,
        response: WeatherAPIResponse
    ) -> WeatherCondition {
        decorator.weatherCondition(
            sunrise: response.sunrise,
            sunset: response.sunset
        )
    }
}
