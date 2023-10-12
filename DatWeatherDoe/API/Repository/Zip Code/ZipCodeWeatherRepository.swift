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

        do {
            try validateZipCode()
            let url = try buildURL()
            performRequest(url: url, completion: { [weak self] result in
                self?.parseNetworkResult(result: result, completion: completion)
            })
        } catch {
            logger.error("Getting weather via zip code failed. Zip code is incorrect!")

            completion(.failure(error))
        }
    }

    private func validateZipCode() throws {
        try ZipCodeValidator(zipCode: zipCode).validate()
    }

    private func buildURL() throws -> URL {
        try ZipCodeWeatherURLBuilder(appId: appId, zipCode: zipCode).build()
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
