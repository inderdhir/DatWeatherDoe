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
        let repository = selectWeatherRepository(input: .location(coordinates: location))
        let response = try await repository.getWeather(unit: options.unit)
        
        return buildWeatherDataWith(response: response, options: options)
    }
    
    func getWeatherViaCity(
        _ city: String,
        options: WeatherDataBuilder.Options
    ) async throws -> WeatherData {
        let repository = selectWeatherRepository(input: .city(city : city))
        let response = try await repository.getWeather(unit: options.unit)
        
        return buildWeatherDataWith(response: response, options: options)
    }

    func getWeatherViaLatLong(
        _ latLong: String,
        options: WeatherDataBuilder.Options
    ) async throws -> WeatherData {
        let repository = selectWeatherRepository(input: .latLong(latLong: latLong))
        let response = try await repository.getWeather(unit: options.unit)

        return buildWeatherDataWith(response: response, options: options)
    }
    
    private func selectWeatherRepository(input: WeatherRepositoryInput) -> WeatherRepositoryType {
        switch input {
        case let .location(coordinates):
            return SystemLocationWeatherRepository(
                appId: appId,
                location: coordinates,
                networkClient: NetworkClient(),
                logger: logger
            )
        case let .latLong(latLong):
            return LocationCoordinatesWeatherRepository(
                appId: appId,
                latLong: latLong,
                networkClient: NetworkClient(),
                logger: logger
            )
        case let .city(city):
            return CityWeatherRepository(
                appId: appId,
                city: city,
                networkClient: NetworkClient(),
                logger: logger
            )
        }
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
