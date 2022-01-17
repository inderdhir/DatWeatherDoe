//
//  ZipCodeWeatherRepository.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/14/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class ZipCodeWeatherRepository: WeatherRepositoryType {
    
    private let appId: String
    private let zipCode: String
    private let networkClient: NetworkClient
    private let logger: DatWeatherDoeLoggerType

    init(
        appId: String,
        zipCode: String,
        networkClient: NetworkClient,
        logger: DatWeatherDoeLoggerType
    ) {
        self.appId = appId
        self.zipCode = zipCode
        self.networkClient = networkClient
        self.logger = logger
    }
    
    func getWeather(completion: @escaping (Result<WeatherAPIResponse, Error>) -> Void) {
        logger.debug("Getting weather via zip code")
        
        guard let url = validateZipCodeAndBuildURL(completion: completion) else {
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
    func getWeather() async throws -> WeatherAPIResponse {
        logger.debug("Getting weather via zip code")
        
        let url = try await validateZipCodeAndBuildURL()
        let data = try await performRequest(url: url)
        return try parseWeatherData(data)
    }
    
    private func validateZipCodeAndBuildURL(
        completion: @escaping (Result<WeatherAPIResponse, Error>) -> Void
    ) -> URL? {
        guard validateZipCode() else {
            logger.error("Getting weather via zip code failed. Zip code is empty!")
            
            completion(.failure(WeatherError.zipCodeEmpty))
            return nil
        }
        
        guard let url = buildURL() else {
            completion(.failure(WeatherError.unableToConstructUrl))
            return nil
        }
        
        return url
    }
    
    @available(macOS 12.0, *)
    private func validateZipCodeAndBuildURL() async throws -> URL {
        guard validateZipCode() else {
            logger.error("Getting weather via zip code failed. Zip code is empty!")
            
            throw WeatherError.zipCodeEmpty
        }
        
        guard let url = buildURL() else {
            throw WeatherError.unableToConstructUrl
        }
        
        return url
    }
    
    private func validateZipCode() -> Bool {
        ZipCodeValidator(zipCode: zipCode).validate()
    }
    
    private func buildURL() -> URL? {
        ZipCodeWeatherURLBuilder(appId: appId, zipCode: zipCode).build()
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
