//
//  WeatherRetriever.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/30/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import CoreLocation
import AppKit
import os

final class WeatherRepository: WeatherRepositoryType {

    private let apiUrl = "https://api.openweathermap.org/data/2.5/weather"
    private let appId: String
    private let configManager: ConfigManagerType
    private let logger: DatWeatherDoeLoggerType

    init(configManager: ConfigManagerType, logger: DatWeatherDoeLoggerType) {
        guard let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist"),
            let plist = NSDictionary(contentsOfFile: filePath),
            let appId = plist["OPENWEATHERMAP_APP_ID"] as? String else {
            fatalError("Unable to find OPENWEATHERMAP_APP_ID in Keys.plist")
        }
        self.appId = appId
        self.configManager = configManager
        self.logger = logger
    }

    func getWeather(
        zipCode: String,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    ) {
        logger.logDebug("Getting weather via zip code")

        guard !zipCode.isEmpty else {
            logger.logError("Getting weather via zip code failed. Zip code is empty!")
            completion(.failure(.zipCodeEmpty))
            return
        }

        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "zip", value: zipCode)
        ]
        var urlComps = URLComponents(string: apiUrl)
        urlComps?.queryItems = queryItems
        guard let url = urlComps?.url else {
            completion(.failure(.unableToConstructUrl))
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let strongSelf = self, let data = data, error == nil else {
                self?.logger.logError("Getting weather via zip code failed")

                completion(.failure(.networkError))
                return
            }

            completion(strongSelf.parseResponse(data))
        }.resume()
    }

    func getWeather(
        latLong: String,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    ) {
        logger.logDebug("Getting weather via lat / long")

        guard !latLong.isEmpty else {
            logger.logError("Getting weather via lat / long failed. Lat / long is empty!")

            completion(.failure(.latLongEmpty))
            return
        }

        let latLongCombo = latLong.split(separator: ",")
        guard latLongCombo.count == 2 else {
            logger.logError("Incorrect format for lat/lon")

            completion(.failure(.latLongIncorrect))
            return
        }

        guard let lat = CLLocationDegrees(String(latLongCombo[0])),
              let long = CLLocationDegrees(String(latLongCombo[1])) else {
            completion(.failure(.latLongIncorrect))
            return
        }

        getWeather(location: CLLocationCoordinate2D(latitude: lat, longitude: long), completion: completion)
    }

    func getWeather(
        location: CLLocationCoordinate2D,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    ) {
        logger.logDebug("Getting weather via location")

        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "lat", value: String(describing: location.latitude)),
            URLQueryItem(name: "lon", value: String(describing: location.longitude)),
        ]
        var urlComps = URLComponents(string: apiUrl)
        urlComps?.queryItems = queryItems
        guard let url = urlComps?.url else {
            completion(.failure(.unableToConstructUrl))
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let strongSelf = self, let data = data, error == nil else {
                self?.logger.logError("Getting weather via location failed")

                completion(.failure(.networkError))
                return
            }

            completion(strongSelf.parseResponse(data))
        }.resume()
    }

    private func parseResponse(_ data: Data) -> Result<WeatherData, WeatherError> {
        guard let response = try? JSONDecoder().decode(WeatherAPIResponse.self, from: data) else {
            return .failure(.unableToParseWeatherResponse)
        }

        guard let temperatureUnit = TemperatureUnit(rawValue: configManager.temperatureUnit) else {
            return .failure(.unableToParseTemperatureUnit)
        }

        let decorator = WeatherDecorator(
            configManager: configManager,
            logger: logger,
            response: response,
            temperatureUnit: temperatureUnit,
            isShowingHumidity: configManager.isShowingHumidity
        )
        return .success(
            .init(
                textualRepresentation: decorator.textualRepresentation,
                location: response.location,
                weatherCondition: decorator.weatherCondition
            )
        )
    }
}
