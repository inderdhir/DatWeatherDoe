//
//  WeatherRepositoryFactory.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 8/7/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import CoreLocation
import Foundation
import OSLog

protocol WeatherRepositoryFactoryType {
    static func create(
        options: WeatherRepositoryFactory.Options,
        location: CLLocationCoordinate2D
    ) -> WeatherRepositoryType
    static func create(
        options: WeatherRepositoryFactory.Options,
        latLong: String
    ) -> WeatherRepositoryType
    static func create(
        options: WeatherRepositoryFactory.Options,
        city: String
    ) -> WeatherRepositoryType
}

final class WeatherRepositoryFactory: WeatherRepositoryFactoryType {
    struct Options {
        let appId: String
        let networkClient: NetworkClient
        let logger: Logger
    }
    
    static func create(
        options: WeatherRepositoryFactory.Options,
        location: CLLocationCoordinate2D
    ) -> WeatherRepositoryType {
        SystemLocationWeatherRepository(
            appId: options.appId,
            location: location,
            networkClient: options.networkClient,
            logger: options.logger
        )
    }
    
    static func create(
        options: WeatherRepositoryFactory.Options,
        latLong: String
    ) -> WeatherRepositoryType {
        LocationCoordinatesWeatherRepository(
            appId: options.appId,
            latLong: latLong,
            networkClient: options.networkClient,
            logger: options.logger
        )
    }
    
    static func create(
        options: WeatherRepositoryFactory.Options,
        city: String
    ) -> WeatherRepositoryType {
        CityWeatherRepository(
            appId: options.appId,
            city: city,
            networkClient: options.networkClient,
            logger: options.logger
        )
    }
}
