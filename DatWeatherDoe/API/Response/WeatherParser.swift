//
//  WeatherParser.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/10/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class WeatherParser {
    
    private let configManager: ConfigManagerType
    private let logger: DatWeatherDoeLoggerType
    private let responseDecoder = JSONDecoder()
    private let responseDecorator: ResponseDecorator

    init(
        configManager: ConfigManagerType,
        logger: DatWeatherDoeLoggerType
    ) {
        self.configManager = configManager
        self.logger = logger
        self.responseDecorator = ResponseDecorator(
            options: .init(
                temperatureUnit: TemperatureUnit(rawValue: configManager.temperatureUnit)!,
                isWeatherConditionAsTextEnabled: configManager.isWeatherConditionAsTextEnabled,
                isShowingHumidity: configManager.isShowingHumidity,
                isRoundingOff: configManager.isRoundingOffData
            ),
            logger: logger
        )
    }
    
    func parseWeatherData(_ data: Data) -> Result<WeatherData, WeatherError> {
        do {
            let response = try parseNetworkResponse(data)
            let temperatureUnit = try getSelectedTemperatureUnit()
            
            let weatherData = getWeatherData(
                response: response,
                temperatureUnit: temperatureUnit
            )
            return .success(weatherData)
        } catch {
            let weatherError = (error as? WeatherError) ?? WeatherError.other
            return .failure(weatherError)
        }
    }
    
    @available(macOS 12.0, *)
    func parseWeatherData(_ data: Data) async throws -> WeatherData {
        let response = try parseNetworkResponse(data)
        let temperatureUnit = try getSelectedTemperatureUnit()
        
        return getWeatherData(
            response: response,
            temperatureUnit: temperatureUnit
        )
    }
    
    private func parseNetworkResponse(_ data: Data) throws -> WeatherAPIResponse {
        if let response = try? responseDecoder.decode(WeatherAPIResponse.self, from: data) {
            return response
        }
        throw WeatherError.unableToParseWeatherResponse
    }
    
    private func getSelectedTemperatureUnit() throws -> TemperatureUnit {
        if let unit = TemperatureUnit(rawValue: configManager.temperatureUnit) {
            return unit
        }
        throw WeatherError.unableToParseTemperatureUnit
    }
    
    private func getWeatherData(
        response: WeatherAPIResponse,
        temperatureUnit: TemperatureUnit
    ) -> WeatherData {
        responseDecorator.getWeatherData(
            response: response,
            temperatureUnit: temperatureUnit
        )
    }
}
