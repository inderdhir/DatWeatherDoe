//
//  WeatherRepository.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/30/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import CoreLocation

protocol WeatherRepositoryType: AnyObject {
    func getWeather(completion: @escaping (Result<WeatherAPIResponse, Error>) -> Void)
}

final class WeatherRepository {
    
    private let appId: String
    private let logger: DatWeatherDoeLoggerType
    private var repository: WeatherRepositoryType?
    
    init(
        appId: String,
        logger: DatWeatherDoeLoggerType
    ) {
        self.appId = appId
        self.logger = logger
    }

    func getWeatherViaLocation(
        _ location: CLLocationCoordinate2D,
        options: WeatherDataBuilder.Options,
        completion: @escaping (Result<WeatherData, Error>) -> Void
    ) {
        repository = selectWeatherRepository(input: .location(coordinates: location))
        repository?.getWeather(completion: { [weak self] result in
            self?.parseRepositoryResult(
                result,
                options: options,
                completion: completion
            )
        })
    }

    func getWeatherViaLatLong(
        _ latLong: String,
        options: WeatherDataBuilder.Options,
        completion: @escaping (Result<WeatherData, Error>) -> Void
    ) {
        repository = selectWeatherRepository(input: .latLong(latLong: latLong))
        repository?.getWeather(completion: { [weak self] result in
            self?.parseRepositoryResult(result, options: options, completion: completion)
        })
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
        }
    }
    
    private func parseRepositoryResult(
        _ result: Result<WeatherAPIResponse, Error>,
        options: WeatherDataBuilder.Options,
        completion: (Result<WeatherData, Error>) -> Void
    ) {
        switch result {
        case let .success(response):
            let weatherData = buildWeatherDataWith(response: response, options: options)
            completion(.success(weatherData))
        case let .failure(error):
            completion(.failure(error))
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
