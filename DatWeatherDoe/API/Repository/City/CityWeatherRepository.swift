//
//  CityWeatherRepository.swift
//  DatWeatherDoe
//
//  Created by preckrasno on 14.02.2023.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation

final class CityWeatherRepository: WeatherRepositoryType {
    
    private let appId: String
    private let city: String
    private let networkClient: NetworkClient
    private let logger: DatWeatherDoeLoggerType

    init(
        appId: String,
        city: String,
        networkClient: NetworkClient,
        logger: DatWeatherDoeLoggerType
    ) {
        self.appId = appId
        self.city = city
        self.networkClient = networkClient
        self.logger = logger
    }
    
    func getWeather(completion: @escaping (Result<WeatherAPIResponse, Error>) -> Void) {
        logger.debug("Getting weather via city")
        
        do {
            try validateCity()
            let url = try buildURL()
            performRequest(url: url, completion: { [weak self] result in
                self?.parseNetworkResult(result: result, completion: completion)
            })
        } catch {
            logger.error("Getting weather via city failed.")
            
            completion(.failure(error))
        }
    }
    
    private func validateCity() throws {
        try CityValidator(city: city).validate()
    }
    
    private func buildURL() throws -> URL {
        try CityWeatherURLBuilder(appId: appId, city: city).build()
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
