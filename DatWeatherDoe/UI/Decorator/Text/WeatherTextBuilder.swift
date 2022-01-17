//
//  WeatherTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

final class WeatherTextBuilder {
    
    struct Options {
        let isWeatherConditionAsTextEnabled: Bool
        let temperatureOptions: TemperatureTextBuilder.Options
        let isShowingHumidity: Bool
    }
    
    private let response: WeatherAPIResponse
    private let options: Options
    private let logger: DatWeatherDoeLoggerType
    
    init(
        response: WeatherAPIResponse,
        options: Options,
        logger: DatWeatherDoeLoggerType
    ) {
        self.response = response
        self.options = options
        self.logger = logger
    }
    
    func build() -> String {
        let finalString = buildWeatherConditionAsText() |>
        appendTemperatureAsText |>
        appendHumidityText
        
        return finalString
    }
    
    private func buildWeatherConditionAsText() -> String? {
        guard options.isWeatherConditionAsTextEnabled else { return nil }
        
        let weatherCondition = WeatherConditionBuilder(response: response).build()
        return WeatherConditionTextMapper().mapConditionToText(weatherCondition)
    }
    
    private func appendTemperatureAsText(initial: String?) -> String {
        TemperatureTextBuilder(
            initial: initial,
            response: response,
            options: options.temperatureOptions
        ).build()
    }
    
    private func appendHumidityText(initial: String) -> String {
        guard options.isShowingHumidity else { return initial }
        
        return HumidityTextBuilder(
            initial: initial,
            humidity: response.humidity,
            logger: logger
        ).build()
    }
}
