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

final class WeatherViewModel: WeatherViewModelType {
    
    weak var delegate: WeatherViewModelDelegate?
    private let configManager: ConfigManagerType
    private let logger: DatWeatherDoeLoggerType
    private let errorStrings: ErrorStrings
    private let weatherRepository: WeatherRepositoryType
    private let weatherTimerSerialQueue = DispatchQueue(label: "Weather Timer Serial Queue")
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
    
    func getUpdatedWeather() {
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
            getWeatherAfterUpdatingLocation()
        case .latLong:
            getWeatherViaLocationCoordinates()
        case .zipCode:
            getWeatherViaZipCode()
        default:
            logger.error("Unable to get weather source")
        }
    }
    
    private func getWeatherAfterUpdatingLocation() {
        locationFetcher.startUpdatingLocation()
    }
    
    private func getWeatherViaLocationCoordinates() {
        guard let latLong = configManager.weatherSourceText else {
            delegate?.didFailToUpdateWeatherData(errorStrings.latLongErrorString)
            return
        }
        
        if #available(macOS 12.0, *) {
            getWeatherWithLatLong(latLong)
        } else {
            getWeatherWithLatLongLegacy(latLong)
        }
    }
    
    private func getWeatherViaZipCode() {
        guard let zipCode = configManager.weatherSourceText else {
            delegate?.didFailToUpdateWeatherData(errorStrings.zipCodeErrorString)
            return
        }
        
        if #available(macOS 12.0, *) {
            getWeatherWithZipCode(zipCode)
        } else {
            getWeatherWithZipCodeLegacy(zipCode)
        }
    }
    
    @available(macOS 12.0, *)
    private func getWeatherWithLatLong(_ latLong: String) {
        Task {
            do {
                let weatherData = try await weatherRepository.getWeather(latLong: latLong)
                delegate?.didUpdateWeatherData(weatherData)
            }
            catch {
                guard let weatherError = error as? WeatherError else { return }
                
                let isLatLongError = weatherError == WeatherError.latLongEmpty ||
                weatherError == WeatherError.latLongIncorrect
                let errorString = isLatLongError ?
                errorStrings.latLongErrorString :
                errorStrings.networkErrorString
                
                delegate?.didFailToUpdateWeatherData(errorString)
            }
        }
    }
    
    private func getWeatherWithLatLongLegacy(_ latLong: String) {
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
    
    @available(macOS 12.0, *)
    private func getWeatherWithZipCode(_ zipCode: String) {
        Task {
            do {
                let weatherData = try await weatherRepository.getWeather(zipCode: zipCode)
                delegate?.didUpdateWeatherData(weatherData)
            } catch {
                guard let weatherError = error as? WeatherError else { return }
                
                let errorString = weatherError == WeatherError.zipCodeEmpty ?
                errorStrings.zipCodeErrorString :
                errorStrings.networkErrorString
                
                delegate?.didFailToUpdateWeatherData(errorString)
            }
        }
    }
    
    private func getWeatherWithZipCodeLegacy(_ zipCode: String) {
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
    
    private func getWeatherViaLocation(_ location: CLLocationCoordinate2D) {
        if #available(macOS 12.0, *) {
            getWeatherWithLocation(location)
        } else {
            getWeatherWithLocationLegacy(location)
        }
    }
    
    @available(macOS 12.0, *)
    private func getWeatherWithLocation(_ location: CLLocationCoordinate2D) {
        Task {
            do {
                let weatherData = try await weatherRepository.getWeather(location: location)
                delegate?.didUpdateWeatherData(weatherData)
            } catch {
                delegate?.didFailToUpdateWeatherData(errorStrings.networkErrorString)
            }
        }
    }
    
    private func getWeatherWithLocationLegacy(_ location: CLLocationCoordinate2D) {
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
}

// MARK: WeatherLocationFetcherDelegate

extension WeatherViewModel: WeatherLocationFetcherDelegate {
    func didUpdateLocation(_ location: CLLocationCoordinate2D, isCachedLocation: Bool) {
        getWeatherViaLocation(location)
    }
    
    func didFailLocationUpdate(_ error: Error?) {
        delegate?.didFailToUpdateWeatherData(errorStrings.locationErrorString)
    }
}
