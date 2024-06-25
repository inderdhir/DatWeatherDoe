//
//  SystemLocationWeatherRepository.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation
import OSLog

final class SystemLocationWeatherRepository: WeatherRepositoryType {
    private let appId: String
    private let location: CLLocationCoordinate2D
    private let networkClient: NetworkClientType
    private let logger: Logger

    init(
        appId: String,
        location: CLLocationCoordinate2D,
        networkClient: NetworkClientType,
        logger: Logger
    ) {
        self.appId = appId
        self.location = location
        self.networkClient = networkClient
        self.logger = logger
    }

    func getWeather() async throws -> WeatherAPIResponse {
        logger.debug("Getting weather via location")

        do {
            let url = try WeatherURLBuilder(appId: appId, location: location).build()
            let data = try await networkClient.performRequest(url: url)
            return try WeatherAPIResponseParser().parse(data)
        } catch {
            logger.error("Getting weather via location failed")

            throw error
        }
    }
}
