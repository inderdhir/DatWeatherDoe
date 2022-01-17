//
//  LocationSystemWeatherRepository.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation

final class LocationSystemWeatherRepository: WeatherRepositoryType {
    
    private let appId: String
    private let location: CLLocationCoordinate2D
    private let networkClient: NetworkClient
    private let logger: DatWeatherDoeLoggerType
    
    init(
        appId: String,
        location: CLLocationCoordinate2D,
        networkClient: NetworkClient,
        logger: DatWeatherDoeLoggerType
    ) {
        self.appId = appId
        self.location = location
        self.networkClient = networkClient
        self.logger = logger
    }
    
    func getWeather(completion: @escaping (Result<WeatherAPIResponse, Error>) -> Void) {
        logger.debug("Getting weather via location")
        
        guard let url = buildURL(location) else {
            completion(.failure(WeatherError.unableToConstructUrl))
            return
        }
        
        performRequest(
            url: url,
            completion: { [weak self] result in
                self?.parseRepositoryResult(result, completion: completion)
            }
        )
    }
    
    @available(macOS 12.0, *)
    func getWeather() async throws -> WeatherAPIResponse {
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
    
    private func parseRepositoryResult(
        _ result: Result<Data, Error>,
        completion: @escaping (Result<WeatherAPIResponse, Error>) -> Void
    ) {
        switch result {
        case let .success(data):
            do {
                let apiResponse = try parseWeatherData(data)
                completion(.success(apiResponse))
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
