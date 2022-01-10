//
//  WeatherViewModel.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation
import Foundation

protocol WeatherViewModelDelegate: AnyObject {
    func didUpdateWeatherData(_ data: WeatherData)
    func didFailToUpdateWeatherData(_ error: String)
}

final class WeatherViewModel {
    
    weak var delegate: WeatherViewModelDelegate?
    private let weatherTimerSerialQueue = DispatchQueue(label: "Weather Timer Serial Queue")
    private let configManager: ConfigManagerType
    private let logger: DatWeatherDoeLoggerType
    private let errorStrings: ErrorStrings
    private let weatherRepository: WeatherRepositoryType
    private var weatherTimer: Timer?
    private lazy var locationFetcher: WeatherLocationFetcher = {
        let locationFetcher = WeatherLocationFetcher(logger: logger)
        locationFetcher.delegate = self
        return locationFetcher
    }()
    
    init(
        appId: String,
        errorStrings: ErrorStrings,
        configManager: ConfigManagerType,
        logger: DatWeatherDoeLoggerType
    ) {
        self.errorStrings = errorStrings
        self.configManager = configManager
        self.logger = logger
        self.weatherRepository = WeatherRepository(
            appId: appId,
            configManager: configManager,
            logger: logger
        )
    }
    
    func resetWeatherTimer() {
        weatherTimerSerialQueue.sync {
            weatherTimer?.invalidate()
            weatherTimer = Timer.scheduledTimer(
                withTimeInterval: configManager.refreshInterval,
                repeats: true,
                block: { [weak self] _ in self?.getWeather() })
            weatherTimer?.fire()
        }
    }
    
    @objc func getWeather() {
        switch WeatherSource(rawValue: configManager.weatherSource) {
        case .location:
            getWeatherViaLocation()
        case .latLong:
            getWeatherViaLocationCoordinates()
        case .zipCode:
            getWweatherViaZipCode()
        default:
            logger.logError("Unable to get weather source")
        }
    }
    
    private func getWeatherViaLocation() {
        locationFetcher.startUpdatingLocation()
    }
    
    private func getWeatherViaLocationCoordinates() {
        guard let latLong = configManager.weatherSourceText else {
            delegate?.didFailToUpdateWeatherData(errorStrings.latLongErrorString)
            return
        }
        
        getWeather(latLong: latLong)
    }
    
    private func getWeather(latLong: String) {
        weatherRepository.getWeather(latLong: latLong, completion: { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case let .success(weatherData):
                self.delegate?.didUpdateWeatherData(weatherData)
            case let .failure(error):
                let isLatLongError = error == .latLongEmpty || error == .latLongIncorrect
                let errorString = isLatLongError ?
                    self.errorStrings.latLongErrorString :
                    self.errorStrings.networkErrorString
                
                self.delegate?.didFailToUpdateWeatherData(errorString)
            }
        })
    }
    
    private func getWweatherViaZipCode() {
        guard let zipCode = configManager.weatherSourceText else {
            delegate?.didFailToUpdateWeatherData(errorStrings.zipCodeErrorString)
            return
        }
        
        getWeather(zipCode: zipCode)
    }
    
    private func getWeather(zipCode: String) {
        weatherRepository.getWeather(zipCode: zipCode, completion: { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case let .success(weatherData):
                self.delegate?.didUpdateWeatherData(weatherData)
            case let .failure(error):
                let errorString = error == .zipCodeEmpty ?
                self.errorStrings.zipCodeErrorString :
                self.errorStrings.networkErrorString
                
                self.delegate?.didFailToUpdateWeatherData(errorString)
            }
        })
    }
}

// MARK: WeatherLocationFetcherDelegate

extension WeatherViewModel: WeatherLocationFetcherDelegate {
    func didUpdateLocation(_ location: CLLocationCoordinate2D, isCachedLocation: Bool) {
        weatherRepository.getWeather(
            location: location,
            completion: { [weak self] result in
                guard let `self` = self else { return }
                
                switch result {
                case let .success(weatherData):
                    self.delegate?.didUpdateWeatherData(weatherData)
                case .failure:
                    self.delegate?.didFailToUpdateWeatherData(self.errorStrings.networkErrorString)
                }
            })
    }
    
    func didFailLocationUpdate(_ error: Error?) {
        delegate?.didFailToUpdateWeatherData(errorStrings.locationErrorString)
    }
}
