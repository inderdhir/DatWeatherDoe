//
//  LocationCoordinatesWeatherRepository.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/14/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation

final class LocationCoordinatesWeatherRepository: WeatherRepositoryType {
    
    private let appId: String
    private let latLong: String
    private let networkClient: NetworkClient
    private let logger: DatWeatherDoeLoggerType
    
    init(
        appId: String,
        latLong: String,
        networkClient: NetworkClient,
        logger: DatWeatherDoeLoggerType
    ) {
        self.appId = appId
        self.latLong = latLong
        self.networkClient = networkClient
        self.logger = logger
    }
    
    func getWeather(completion: @escaping (Result<WeatherAPIResponse, Error>) -> Void) {
        logger.debug("Getting weather via lat/long")
        
        do {
            let location = try getLocationCoordinatesFrom(latLong)
            let url = try buildURL(location)
            performRequest(url: url, completion: { [weak self] result in
                self?.parseNetworkResult(result: result, completion: completion)
            })
        } catch {
            logger.error("Getting weather via lat/long failed")

            completion(.failure(error))
        }
    }
    
    private func getLocationCoordinatesFrom(_ latLong: String) throws -> CLLocationCoordinate2D {
        do {
            try validateCoordinates(latLong)
            let latAndlong = try parseLocationCoordinates(latLong)
            return latAndlong
        } catch {            
            throw error
        }
    }
    
    private func validateCoordinates(_ latLong: String) throws {
        try LocationValidator(latLong: latLong).validate()
    }
    
    private func parseLocationCoordinates(_ latLong: String) throws -> CLLocationCoordinate2D {
        try LocationParser().parseCoordinates(latLong)
    }
    
    private func buildURL(_ location: CLLocationCoordinate2D) throws -> URL {
        try LocationWeatherURLBuilder(appId: appId, location: location).build()
    }
    
    private func performRequest(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        networkClient.performRequest(url: url, completion: completion)
    }
    
    private func parseNetworkResult(
        result: Result<Data, Error>,
        completion: @escaping (Result<WeatherAPIResponse, Error>) -> Void
    ) {
        switch result {
        case let .success(data):
            do {
                let weatherData = try parseWeatherData(data)
                completion(.success(weatherData))
            } catch {
                let weatherError = (error as? WeatherError) ?? .other
                completion(.failure(weatherError))
            }
        case let .failure(error):
            let weatherError = (error as? WeatherError) ?? .other
            completion(.failure(weatherError))
        }
    }
    
    private func parseWeatherData(_ data: Data) throws -> WeatherAPIResponse {
        try WeatherAPIResponseParser().parse(data)
    }
}
