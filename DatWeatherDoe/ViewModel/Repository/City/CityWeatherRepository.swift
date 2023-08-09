//
//  CityWeatherRepository.swift
//  DatWeatherDoe
//
//  Created by preckrasno on 14.02.2023.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation
import OSLog

final class CityWeatherRepository: WeatherRepositoryType {
    
    private let appId: String
    private let city: String
    private let networkClient: NetworkClient
    private let logger: Logger

    init(
        appId: String,
        city: String,
        networkClient: NetworkClient,
        logger: Logger
    ) {
        self.appId = appId
        self.city = city
        self.networkClient = networkClient
        self.logger = logger
    }
    
    func getWeather(unit: MeasurementUnit) async throws -> WeatherAPIResponse {
        logger.debug("Getting weather via city")

        do {
            try CityValidator(city: city).validate()
            let url = try CityWeatherURLBuilder(appId: appId, city: city).build(unit: unit)
            let data = try await networkClient.performRequest(url: url)
            return try WeatherAPIResponseParser().parse(data)
        } catch {
            logger.error("Getting weather via city failed.")
            
            throw error
        }
    }
}
