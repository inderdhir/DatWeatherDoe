//
//  WeatherRetriever.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/30/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import CoreLocation
import AppKit

private enum NetworkRequestType {
    case zipCode, location
}

final class WeatherRepository: WeatherRepositoryType {
    
    private let apiUrlString = "https://api.openweathermap.org/data/2.5/weather"
    private let appId: String
    private let configManager: ConfigManagerType
    private let logger: DatWeatherDoeLoggerType
    private let responseDecoder = JSONDecoder()
    
    init(
        appId: String,
        configManager: ConfigManagerType,
        logger: DatWeatherDoeLoggerType
    ) {
        self.appId = appId
        self.configManager = configManager
        self.logger = logger
    }
    
    func getWeather(
        zipCode: String,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    ) {
        logger.logDebug("Getting weather via zip code")
        
        guard validateZipCode(zipCode) else {
            completion(.failure(.zipCodeEmpty))
            return
        }
        
        guard let url = constructUrl(zipCode: zipCode) else {
            completion(.failure(.unableToConstructUrl))
            return
        }
        
        performNetworkRequest(type: .zipCode, url: url, completion: completion)
    }
    
    func getWeather(
        latLong: String,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    ) {
        logger.logDebug("Getting weather via lat/long")
        
        guard validateCoordinates(latLong: latLong) else {
            completion(.failure(.latLongEmpty))
            return
        }
        
        guard let latAndlong = parseLocationCoordinates(latLong) else {
            completion(.failure(.latLongIncorrect))
            return
        }
        
        let location = CLLocationCoordinate2D(
            latitude: latAndlong.0,
            longitude: latAndlong.1
        )
        getWeather(location: location, completion: completion)
    }
    
    func getWeather(
        location: CLLocationCoordinate2D,
        completion: @escaping (Result<WeatherData, WeatherError>) -> Void
    ) {
        logger.logDebug("Getting weather via location")
        
        guard let url = constructUrl(location: location) else {
            completion(.failure(.unableToConstructUrl))
            return
        }
        
        performNetworkRequest(type: .location, url: url, completion: completion)
    }
    
    private func validateZipCode(_ zipCode: String) -> Bool {
        if zipCode.isEmpty {
            logger.logError("Getting weather via zip code failed. Zip code is empty!")
            return false
        }
        return true
    }
    
    private func constructUrl(zipCode: String) -> URL? {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "zip", value: zipCode)
        ]
        
        var urlComps = URLComponents(string: apiUrlString)
        urlComps?.queryItems = queryItems
        return urlComps?.url
    }
    
    private func validateCoordinates(latLong: String) -> Bool {
        if latLong.isEmpty {
            logger.logError("Getting weather via lat/long failed. Lat/ long is empty!")
            return false
        }
        return true
    }
    
    private func parseLocationCoordinates(_ latLong: String) -> (CLLocationDegrees, CLLocationDegrees)? {
        let latLongCombo = latLong.split(separator: ",")
        guard latLongCombo.count == 2 else {
            logger.logError("Incorrect format for lat/lon")
            
            return nil
        }
        
        guard let lat = CLLocationDegrees(String(latLongCombo[0])),
              let long = CLLocationDegrees(String(latLongCombo[1])) else {
                  logger.logError("Unable to get CLLocationDegrees from lat/long")
                  
                  return nil
              }
        
        return (lat, long)
    }
    
    private func constructUrl(location: CLLocationCoordinate2D) -> URL? {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "lat", value: String(describing: location.latitude)),
            URLQueryItem(name: "lon", value: String(describing: location.longitude)),
        ]
        
        var urlComps = URLComponents(string: apiUrlString)
        urlComps?.queryItems = queryItems
        return urlComps?.url
    }
    
    private func performNetworkRequest(
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
            
            completion(self.getWeatherDataFromNetworkResponse(data))
        }.resume()
    }
    
    private func logNetworkError(type: NetworkRequestType) {
        if type == .zipCode {
            logger.logError("Getting weather via zip code failed")
        } else if type == .location {
            logger.logError("Getting weather via location failed")
        }
    }
    
    private func getWeatherDataFromNetworkResponse(_ data: Data) -> Result<WeatherData, WeatherError> {
        do {
            let response = try parseNetworkResponse(data)
            let temperatureUnit = try getSelectedTemperatureUnit()
            
            let weatherData = getWeatherData(
                response: response,
                temperatureUnit: temperatureUnit
            )
            return .success(weatherData)
        } catch {
            let weatherError = (error as? WeatherError) ?? WeatherError.other
            return .failure(weatherError)
        }
    }
    
    private func parseNetworkResponse(_ data: Data) throws -> WeatherAPIResponse {
        if let response = try? responseDecoder.decode(WeatherAPIResponse.self, from: data) {
            return response
        }
        throw WeatherError.unableToParseWeatherResponse
    }
    
    private func getSelectedTemperatureUnit() throws -> TemperatureUnit {
        if let unit = TemperatureUnit(rawValue: configManager.temperatureUnit) {
            return unit
        }
        throw WeatherError.unableToParseTemperatureUnit
    }
    
    private func getWeatherData(
        response: WeatherAPIResponse,
        temperatureUnit: TemperatureUnit
    ) -> WeatherData {
        let decoratorOptions = constructDecoratorOptions(
            configManager: configManager,
            temperatureUnit: temperatureUnit
        )
        let decorator = WeatherDecorator(
            logger: logger,
            response: response,
            options: decoratorOptions
        )
        
        return .init(
            cityId: response.cityId,
            textualRepresentation: getTextualRepresentation(
                decorator: decorator,
                response: response
            ),
            location: response.location,
            weatherCondition: getWeatherCondition(decorator: decorator, response: response)
        )
    }
    
    private func constructDecoratorOptions(
        configManager: ConfigManagerType,
        temperatureUnit: TemperatureUnit
    ) -> WeatherDecoratorOptions {
        .init(
            temperatureUnit: temperatureUnit,
            isWeatherConditionAsTextEnabled: configManager.isWeatherConditionAsTextEnabled,
            isShowingHumidity:  configManager.isShowingHumidity,
            isRoundingOffData: configManager.isRoundingOffData
        )
    }
    
    private func getTextualRepresentation(
        decorator: WeatherDecorator,
        response: WeatherAPIResponse
    ) -> String {
        decorator.textualRepresentation(
            sunrise: response.sunrise,
            sunset: response.sunset
        )
    }
    
    private func getWeatherCondition(
        decorator: WeatherDecorator,
        response: WeatherAPIResponse
    ) -> WeatherCondition {
        decorator.weatherCondition(
            sunrise: response.sunrise,
            sunset: response.sunset
        )
    }
}
