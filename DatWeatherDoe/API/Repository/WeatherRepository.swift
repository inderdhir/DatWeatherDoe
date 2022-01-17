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
    
    @available(macOS 12.0, *)
    func getWeather() async throws -> WeatherAPIResponse
}

final class WeatherRepository {
    
    private let appId: String
    private let logger: DatWeatherDoeLoggerType
    
    init(appId: String, logger: DatWeatherDoeLoggerType) {
        self.appId = appId
        self.logger = logger
    }

    @available(macOS 12.0, *)
    func getWeatherViaLocation(
        _ location: CLLocationCoordinate2D,
        options: WeatherDataBuilder.Options
    ) async throws -> WeatherData {
        let locationRepository = selectWeatherRepository(
            input: .location(coordinates: location)
        )
        let response = try await locationRepository.getWeather()
        return buildWeatherDataWith(response: response, options: options)
    }

    func getWeatherViaLocation(
        _ location: CLLocationCoordinate2D,
        options: WeatherDataBuilder.Options,
        completion: @escaping (Result<WeatherData, Error>) -> Void
    ) {
        let locationRepository = selectWeatherRepository(
            input: .location(coordinates: location)
        )
        locationRepository.getWeather(completion: { [weak self] result in
            self?.parseRepositoryResult(
                result,
                options: options,
                completion: completion
            )
        })
    }

    @available(macOS 12.0, *)
    func getWeatherViaZipCode(
        _ zipCode: String,
        options: WeatherDataBuilder.Options
    ) async throws -> WeatherData {
        let zipCodeRepository = selectWeatherRepository(input: .zipCode(code: zipCode))
        let response = try await zipCodeRepository.getWeather()
        return buildWeatherDataWith(response: response, options: options)
    }
    
    func getWeatherForZipCode(
        _ zipCode: String,
        options: WeatherDataBuilder.Options,
        completion: @escaping (Result<WeatherData, Error>) -> Void
    ) {
        let zipCodeRepository = selectWeatherRepository(input: .zipCode(code: zipCode))
        zipCodeRepository.getWeather(completion: { [weak self] result in
            self?.parseRepositoryResult(
                result,
                options: options,
                completion: completion
            )
        })
    }
    
    @available(macOS 12.0, *)
    func getWeatherViaLatLong(
        _ latLong: String,
        options: WeatherDataBuilder.Options
    ) async throws -> WeatherData {
        let locationCoordinatesRepository = selectWeatherRepository(
            input: .latLong(latLong: latLong)
        )
        let response = try await locationCoordinatesRepository.getWeather()
        return buildWeatherDataWith(response: response, options: options)
    }
    
    func getWeatherViaLatLong(
        _ latLong: String,
        options: WeatherDataBuilder.Options,
        completion: @escaping (Result<WeatherData, Error>) -> Void
    ) {
        let locationCoordinatesRepository = selectWeatherRepository(
            input: .latLong(latLong: latLong)
        )
        locationCoordinatesRepository.getWeather(completion: { [weak self] result in
            self?.parseRepositoryResult(
                result,
                options: options,
                completion: completion
            )
        })
    }
    
    private func selectWeatherRepository(input: WeatherRepositoryInput) -> WeatherRepositoryType {
        switch input {
        case let .location(coordinates):
            return LocationSystemWeatherRepository(
                appId: appId,
                location: coordinates,
                networkClient: NetworkClient(),
                logger: logger
            )
        case let .zipCode(zipCode):
            return ZipCodeWeatherRepository(
                appId: appId,
                zipCode: zipCode,
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
