//
//  WeatherDataBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 5/22/21.
//  Copyright © 2021 Inder Dhir. All rights reserved.
//

import Foundation
import OSLog

protocol WeatherDataBuilderType: AnyObject {
    func build() -> WeatherData
}

final class WeatherDataBuilder: WeatherDataBuilderType {
    struct Options {
        let unit: MeasurementUnit
        let showWeatherIcon: Bool
        let textOptions: WeatherTextBuilder.Options
    }

    private let response: WeatherAPIResponse
    private let options: WeatherDataBuilder.Options
    private let logger: Logger

    init(
        response: WeatherAPIResponse,
        options: WeatherDataBuilder.Options,
        logger: Logger
    ) {
        self.response = response
        self.options = options
        self.logger = logger
    }

    func build() -> WeatherData {
        .init(
            showWeatherIcon: options.showWeatherIcon,
            textualRepresentation: buildTextualRepresentation(),
            weatherCondition: buildWeatherCondition(),
            response: response
        )
    }

    private func buildTextualRepresentation() -> String {
        WeatherTextBuilder(
            response: response,
            options: options.textOptions,
            logger: logger
        ).build()
    }

    private func buildWeatherCondition() -> WeatherCondition {
        WeatherConditionBuilder(response: response).build()
    }
}
