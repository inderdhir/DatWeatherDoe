//
//  SystemLocationWeatherRepository.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation

final class SystemLocationWeatherRepository: WeatherRepositoryType {
    
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
        
        do {
            let url = try buildURL(location)
            performRequest(url: url, completion: { [weak self] result in
                self?.parseRepositoryResult(result, completion: completion)
            })
        } catch {
            completion(.failure(error))
        }
    }
    
    private func buildURL(_ location: CLLocationCoordinate2D) throws -> URL {
        try LocationWeatherURLBuilder(appId: appId, location: location).build()
    }
    
    private func performRequest(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        networkClient.performRequest(url: url, completion: completion)
    }
    
    private func parseRepositoryResult(
        _ result: Result<Data, Error>,
        completion: @escaping (Result<WeatherAPIResponse, Error>) -> Void
    ) {
        switch result {
        case let .success(data):
            do {
                let response = try parseWeatherData(data)
                completion(.success(response))
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
