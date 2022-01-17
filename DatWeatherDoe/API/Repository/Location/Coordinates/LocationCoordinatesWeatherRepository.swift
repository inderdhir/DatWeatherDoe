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
        
        guard let location = getLocation(latLong, completion: completion) else { return }
        getWeather(location: location, completion: completion)
    }
    
    @available(macOS 12.0, *)
    func getWeather() async throws -> WeatherAPIResponse {
        logger.debug("Getting weather via lat/long")

        guard validateCoordinates(latLong) else {
            logger.error("Getting weather via lat/long failed. Lat/ long is empty!")
            
            throw WeatherError.latLongEmpty
        }

        guard let latAndlong = parseLocationCoordinates(latLong) else {
            logger.error("Getting weather via lat/long failed. Unable to parse location coordinates")

            throw WeatherError.latLongIncorrect
        }

        let location = CLLocationCoordinate2D(
            latitude: latAndlong.0,
            longitude: latAndlong.1
        )
        return try await getWeather(location: location)
    }
    
    private func getLocation(
        _ latLong: String,
        completion: @escaping (Result<WeatherAPIResponse, Error>) -> Void
    ) -> CLLocationCoordinate2D? {
        guard validateCoordinates(latLong) else {
            logger.error("Getting weather via lat/long failed. Lat/ long is empty!")
            
            completion(.failure(WeatherError.latLongEmpty))
            return nil
        }
        
        guard let latAndlong = parseLocationCoordinates(latLong) else {
            logger.error("Getting weather via lat/long failed. Unable to parse location coordinates")
            
            completion(.failure(WeatherError.latLongIncorrect))
            return nil
        }
        
        return CLLocationCoordinate2D(latitude: latAndlong.0, longitude: latAndlong.1)
    }
    
    private func validateCoordinates(_ latLong: String) -> Bool {
        LocationValidator(latLong: latLong).validate()
    }
    
    private func parseLocationCoordinates(_ latLong: String)
    -> (CLLocationDegrees, CLLocationDegrees)? {
        LocationParser().parseCoordinates(latLong)
    }
    
    private func getWeather(
        location: CLLocationCoordinate2D,
        completion: @escaping (Result<WeatherAPIResponse, Error>) -> Void
    ) {
        logger.debug("Getting weather via location")
        
        guard let url = buildURL(location) else {
            completion(.failure(WeatherError.unableToConstructUrl))
            return
        }
        
        performRequest(
            url: url,
            completion: { [weak self] result in
                self?.parseNetworkResult(result: result, completion: completion)
            }
        )
    }
    
    @available(macOS 12.0, *)
    private func getWeather(location: CLLocationCoordinate2D) async throws -> WeatherAPIResponse {
        logger.debug("Getting weather via location")

        guard let url = buildURL(location) else {
            throw WeatherError.unableToConstructUrl
        }
        
        let data = try await performRequest(url: url)
        return try parseWeatherData(data)
    }
    
    private func buildURL(_ location: CLLocationCoordinate2D) -> URL? {
        LocationWeatherURLBuilder(appId: appId, location: location)
            .build()
    }
    
    private func performRequest(
        url: URL,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        networkClient.performRequest(url: url, completion: completion)
    }
    
    @available(macOS 12.0, *)
    private func performRequest(url: URL) async throws -> Data {
        try await networkClient.performRequest(url: url)
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
                let weatherError = (error as? WeatherError) ?? WeatherError.other
                completion(.failure(weatherError))
            }
        case let .failure(error):
            let weatherError = (error as? WeatherError) ?? WeatherError.other
            completion(.failure(weatherError))
        }
    }
    
    private func parseWeatherData(_ data: Data) throws -> WeatherAPIResponse {
        try WeatherAPIResponseParser().parse(data)
    }
}
