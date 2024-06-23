//
//  WeatherTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import OSLog

protocol WeatherTextBuilderType {
    func build() -> String
}

final class WeatherTextBuilder: WeatherTextBuilderType {
    struct Options {
        let isWeatherConditionAsTextEnabled: Bool
        let conditionPosition: WeatherConditionPosition
        let valueSeparator: String
        let temperatureOptions: TemperatureTextBuilder.Options
        let isShowingHumidity: Bool
    }

    private let response: WeatherAPIResponse
    private let options: Options
    private let logger: Logger

    init(
        response: WeatherAPIResponse,
        options: Options,
        logger: Logger
    ) {
        self.response = response
        self.options = options
        self.logger = logger
    }

    func build() -> String {
        let finalString = appendTemperatureAsText() |>
            appendHumidityText |>
            buildWeatherConditionAsText
        return finalString
    }

    private func appendTemperatureAsText() -> String {
        TemperatureTextBuilder(
            response: response,
            options: options.temperatureOptions,
            temperatureCreator: TemperatureWithDegreesCreator()
        ).build() ?? ""
    }

    private func appendHumidityText(initial: String) -> String {
        guard options.isShowingHumidity else { return initial }

        return HumidityTextBuilder(
            initial: initial,
            valueSeparator: options.valueSeparator,
            humidity: response.humidity,
            logger: logger
        ).build()
    }

    private func buildWeatherConditionAsText(initial: String) -> String {
        guard options.isWeatherConditionAsTextEnabled else { return initial }

        let weatherCondition = WeatherConditionBuilder(response: response).build()
        let weatherConditionText = WeatherConditionTextMapper().map(weatherCondition)

        let combinedString = options.conditionPosition == .beforeTemperature ?
            [weatherConditionText, initial] :
            [initial, weatherConditionText.lowercased()]

        return combinedString
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

precedencegroup ForwardPipe {
    associativity: left
}

infix operator |>: ForwardPipe

private func |> <T, U>(value: T, function: (T) -> U) -> U {
    function(value)
}
