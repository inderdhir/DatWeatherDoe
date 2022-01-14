//
//  WeatherNetworkModel.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/10/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

enum NetworkRequestType {
    case zipCode, location
}

final class WeatherNetworkModel {
    
    private let logger: DatWeatherDoeLoggerType
    private let responseParser: ResponseParser

    init(configManager: ConfigManagerType, logger: DatWeatherDoeLoggerType) {
        self.logger = logger
        self.responseParser = ResponseParser(
            configManager: configManager,
            logger: logger
        )
    }
    
    func performNetworkRequest(
        type: NetworkRequestType,
        url: URL,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    ) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let `self` = self, let data = data, error == nil else {
                self?.logNetworkError(type: type)
                
                completion(.failure(.networkError))
                return
            }
            
            completion(self.fetchWeatherData(data))
        }.resume()
    }
    
    @available(macOS 12.0, *)
    func performNetworkRequest(
        type: NetworkRequestType,
        url: URL
    ) async throws -> WeatherData {
        let (data, _) = try await URLSession.shared.data(from: url)
        return try await fetchWeatherData(data)
    }
    
    private func logNetworkError(type: NetworkRequestType) {
        if type == .zipCode {
            logger.error("Getting weather via zip code failed")
        } else if type == .location {
            logger.error("Getting weather via location failed")
        }
    }
    
    private func fetchWeatherData(_ data: Data) -> Result<WeatherData, WeatherError> {
        responseParser.parseWeatherData(data)
    }
    
    @available(macOS 12.0, *)
    private func fetchWeatherData(_ data: Data) async throws -> WeatherData {
        try await responseParser.parseWeatherData(data)
    }
}
