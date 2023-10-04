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
    
    func getWeather() async throws -> WeatherAPIResponse {
        logger.debug("Getting weather via lat/long")
        
        do {
            let location = try getLocationCoordinatesFrom(latLong)
            let url = try LocationWeatherURLBuilder(appId: appId, location: location).build()
            let data = try await networkClient.performRequest(url: url)
            return try WeatherAPIResponseParser().parse(data)
        } catch {
            logger.error("Getting weather via lat/long failed")
            
            throw error
        }
    }
    
    private func getLocationCoordinatesFrom(_ latLong: String) throws -> CLLocationCoordinate2D {
        try LocationValidator(latLong: latLong).validate()
        
        let latAndlong = try LocationParser().parseCoordinates(latLong)
        return latAndlong
    }
}
