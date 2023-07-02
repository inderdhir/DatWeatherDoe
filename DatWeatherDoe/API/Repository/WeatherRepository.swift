//
//  WeatherRepository.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/30/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import CoreLocation

protocol WeatherRepositoryType: AnyObject {
    func getWeather(unit: MeasurementUnit) async throws -> WeatherAPIResponse
}

final class WeatherRepository {
    
    private let appId: String
    private let logger: DatWeatherDoeLoggerType
    
    init(
        appId: String,
        logger: DatWeatherDoeLoggerType
    ) {
        self.appId = appId
        self.logger = logger
    }

    func getWeatherViaLocation(
        _ location: CLLocationCoordinate2D,
        options: WeatherDataBuilder.Options
    ) async throws -> WeatherData {
        let repository = SystemLocationWeatherRepository(
            appId: appId,
            location: location,
            networkClient: NetworkClient(),
            logger: logger
        )
        let response = try await repository.getWeather(unit: options.unit)
        
        return buildWeatherDataWith(response: response, options: options)
    }
    
    func getWeatherViaCity(
        _ city: String,
        options: WeatherDataBuilder.Options
    ) async throws -> WeatherData {
        let repository = CityWeatherRepository(
            appId: appId,
            city: city,
            networkClient: NetworkClient(),
            logger: logger
        )
        let response = try await repository.getWeather(unit: options.unit)
        
        return buildWeatherDataWith(response: response, options: options)
    }

    func getWeatherViaLatLong(
        _ latLong: String,
        options: WeatherDataBuilder.Options
    ) async throws -> WeatherData {
        let repository = LocationCoordinatesWeatherRepository(
            appId: appId,
            latLong: latLong,
            networkClient: NetworkClient(),
            logger: logger
        )
        let response = try await repository.getWeather(unit: options.unit)

        return buildWeatherDataWith(response: response, options: options)
    }
    
    private func buildWeatherDataWith(
        response: WeatherAPIResponse,
        options: WeatherDataBuilder.Options
    ) -> WeatherData {
        WeatherDataBuilder(
            response: response,
            options: options,
            logger: logger
        ).build()
    }
}
