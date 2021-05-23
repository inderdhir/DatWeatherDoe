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

    @available(macOS 11.0, *)
    private(set) lazy var logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "DatWeatherDoe",
        category: "WeatherRepository"
    )

    init(configManager: ConfigManagerType) {
        guard let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist"),
            let plist = NSDictionary(contentsOfFile: filePath),
            let appId = plist["OPENWEATHERMAP_APP_ID"] as? String else {
            fatalError("Unable to find OPENWEATHERMAP_APP_ID in Keys.plist")
        }
        self.appId = appId
        self.configManager = configManager
    }

    func getWeather(
        zipCode: String,
        completion: @escaping ((Result<WeatherData, WeatherError>) -> Void)
    ) {
        if #available(macOS 11.0, *) {
            logger.debug("Getting weather via zip code")
        }

        guard !zipCode.isEmpty else {
            if #available(macOS 11.0, *) {
                logger.error("Getting weather via zip code failed. Zip code is empty!")
            }
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
            guard let `self` = self, let data = data, error == nil else {
                if #available(macOS 11.0, *) {
                    self?.logger.error("Getting weather via zip code failed")
                }
                completion(.failure(.networkError))
                return
            }

            completion(self.parseResponse(data))
        }.resume()
    }

    func getWeather(
        latLong: String,
        completion: @escaping ((Result<WeatherData, WeatherError>) -> Void)
    ) {
        if #available(macOS 11.0, *) {
            logger.debug("Getting weather via latLong")
        }

        guard !latLong.isEmpty else {
            if #available(macOS 11.0, *) {
                logger.error("Getting weather via latLong failed. LatLong is empty!")
            }
            completion(.failure(.latLongEmpty))
            return
        }

        let latLongCombo = latLong.split(separator: ",")
        guard latLongCombo.count == 2 else {
            print("Incorrect format for lat/lon")
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
        completion: @escaping ((Result<WeatherData, WeatherError>) -> Void)
    ) {
        if #available(macOS 11.0, *) {
            logger.debug("Getting weather via location")
        }

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
            guard let `self` = self, let data = data, error == nil else {
                if #available(macOS 11.0, *) {
                    self?.logger.error("Getting weather via location failed")
                }
                completion(.failure(.networkError))
                return
            }

            completion(self.parseResponse(data))
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
