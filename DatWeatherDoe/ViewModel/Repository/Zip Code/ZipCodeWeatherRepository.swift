//
//  ZipCodeWeatherRepository.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/14/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation
import OSLog

final class ZipCodeWeatherRepository: WeatherRepositoryType {
    
    private let appId: String
    private let zipCode: String
    private let networkClient: NetworkClientType
    private let logger: Logger

    init(
        appId: String,
        zipCode: String,
        networkClient: NetworkClientType,
        logger: Logger
    ) {
        self.appId = appId
        self.zipCode = zipCode
        self.networkClient = networkClient
        self.logger = logger
    }
    
    func getWeather() async throws -> WeatherAPIResponse {
        logger.debug("Getting weather via zip code")
        
        do {
            try ZipCodeValidator(zipCode: zipCode).validate()
            let url = try ZipCodeWeatherURLBuilder(appId: appId, zipCode: zipCode).build()
            let data = try await networkClient.performRequest(url: url)
            return try WeatherAPIResponseParser().parse(data)
        } catch {
            logger.error("Getting weather via zip code failed")
            
            throw error
        }
    }
}
