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
    
    func getWeather() async throws -> WeatherAPIResponse {
        logger.debug("Getting weather via location")
        
        do {
            let url = try LocationWeatherURLBuilder(appId: appId, location: location).build()
            let data = try await networkClient.performRequest(url: url)
            return try WeatherAPIResponseParser().parse(data)
        } catch {
            logger.error("Getting weather via location failed")
            
            throw error
        }
    }
}
