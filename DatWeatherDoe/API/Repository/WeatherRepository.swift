//
//  WeatherRetriever.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/30/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import CoreLocation
import AppKit

final class WeatherRepository: WeatherRepositoryType {
    
    private let logger: DatWeatherDoeLoggerType
    private let locationParser: LocationParser
    private let urlBuilder: WeatherURLBuilder
    private let networkModel: WeatherNetworkModel
    
    init(
        appId: String,
        configManager: ConfigManagerType,
        logger: DatWeatherDoeLoggerType
    ) {
        self.logger = logger
        self.locationParser = LocationParser()
        self.urlBuilder = WeatherURLBuilder(appId: appId)
        self.networkModel = WeatherNetworkModel(
            configManager: configManager,
            logger: logger
        )
    }
    
    // MARK: ZipCode
    
    func getWeather(
        zipCode: String,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    ) {
        logger.debug("Getting weather via zip code")
            
        guard validateZipCode(zipCode) else {
            logger.error("Getting weather via zip code failed. Zip code is empty!")
            completion(.failure(.zipCodeEmpty))
            return
        }
        
        guard let url = constructUrlWithZipCode(zipCode) else {
            completion(.failure(.unableToConstructUrl))
            return
        }
        
        performNetworkRequest(type: .zipCode, url: url, completion: completion)
    }
    
    @available(macOS 12.0, *)
    func getWeather(zipCode: String) async throws -> WeatherData {
        logger.debug("Getting weather via zip code")
        
        guard validateZipCode(zipCode) else {
            logger.error("Getting weather via zip code failed. Zip code is empty!")
            throw WeatherError.zipCodeEmpty
        }
        
        guard let url = constructUrlWithZipCode(zipCode) else {
            throw WeatherError.unableToConstructUrl
        }
        
        return try await performNetworkRequest(type: .zipCode, url: url)
    }
    
    private func validateZipCode(_ zipCode: String) -> Bool {
        ZipCodeValidator(zipCode: zipCode).validate()
    }
    
    private func constructUrlWithZipCode(_ zipCode: String) -> URL? {
        urlBuilder.buildUrl(zipCode: zipCode)
    }
    
    // MARK: Lat/Long
    
    func getWeather(
        latLong: String,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    ) {
        logger.debug("Getting weather via lat/long")
        
        guard validateCoordinates(latLong) else {
            logger.error("Getting weather via lat/long failed. Lat/ long is empty!")
            
            completion(.failure(.latLongEmpty))
            return
        }
        
        guard let latAndlong = parseLocationCoordinates(latLong) else {
            logger.error("Getting weather via lat/long failed. Unable to parse location coordinates")
            
            completion(.failure(.latLongIncorrect))
            return
        }
        
        let location = CLLocationCoordinate2D(
            latitude: latAndlong.0,
            longitude: latAndlong.1
        )
        getWeather(location: location, completion: completion)
    }
    
    @available(macOS 12.0, *)
    func getWeather(latLong: String) async throws -> WeatherData {
        logger.debug("Getting weather via lat/long")

        guard validateCoordinates(latLong) else {
            logger.error("Getting weather via lat/long failed. Lat/ long is empty!")
            throw WeatherError.latLongEmpty
        }

        guard let latAndlong = parseLocationCoordinates(latLong) else {
            logger.error("Getting weather via lat/long failed. Unable to parse location coordinates")

            throw WeatherError.latLongIncorrect
        }

        let location = CLLocationCoordinate2D(
            latitude: latAndlong.0,
            longitude: latAndlong.1
        )
        return try await getWeather(location: location)
    }
    
    private func validateCoordinates(_ latLong: String) -> Bool {
        LocationValidator(latLong: latLong).validate()
    }
    
    private func parseLocationCoordinates(_ latLong: String)
    -> (CLLocationDegrees, CLLocationDegrees)? {
        locationParser.parseCoordinates(latLong)
    }
    
    // MARK: Location
    
    func getWeather(
        location: CLLocationCoordinate2D,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    ) {
        logger.debug("Getting weather via location")
        
        guard let url = constructUrlWithLocation(location) else {
            completion(.failure(.unableToConstructUrl))
            return
        }
        
        performNetworkRequest(type: .location, url: url, completion: completion)
    }
    
    @available(macOS 12.0, *)
    func getWeather(location: CLLocationCoordinate2D) async throws -> WeatherData {
        logger.debug("Getting weather via location")

        guard let url = constructUrlWithLocation(location) else {
            throw WeatherError.unableToConstructUrl
        }

        return try await performNetworkRequest(type: .location, url: url)
    }

    private func constructUrlWithLocation(_ location: CLLocationCoordinate2D) -> URL? {
        urlBuilder.buildUrl(location: location)
    }
    
    private func performNetworkRequest(
        type: NetworkRequestType,
        url: URL,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    ) {
        networkModel.performNetworkRequest(type: type, url: url, completion: completion)
    }
    
    @available(macOS 12.0, *)
    private func performNetworkRequest(
        type: NetworkRequestType,
        url: URL
    ) async throws -> WeatherData {
        try await networkModel.performNetworkRequest(type: type, url: url)
    }
}
