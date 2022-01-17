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
    private let appId: String
    private let errorStrings: ErrorStrings
    private let weatherTimerSerialQueue = DispatchQueue(label: "Weather Timer Serial Queue")
    private let forecaster = WeatherForecaster()
    private var weatherRepository: WeatherRepository!
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
        self.appId = appId
        self.errorStrings = errorStrings
        self.configManager = configManager
        self.logger = logger
        self.weatherRepository = WeatherRepository(appId: appId, logger: logger)
    }
    
    @objc func getUpdatedWeather() {
        weatherTimerSerialQueue.sync {
            weatherTimer?.invalidate()
            weatherTimer = Timer.scheduledTimer(
                withTimeInterval: configManager.refreshInterval,
                repeats: true,
                block: { [weak self] _ in self?.getWeather() })
            weatherTimer?.fire()
        }
    }
    
    private func getWeather() {
        guard let weatherSource = WeatherSource(rawValue: configManager.weatherSource) else {
            logger.error("Unable to get weather source")
            
            return
        }

        switch weatherSource {
        case .location:
            getWeatherAfterUpdatingLocation()
        case .latLong:
            getWeatherViaLocationCoordinates()
        case .zipCode:
            getWeatherViaZipCode()
        }
    }
    
    func updateCityWith(cityId: Int) {
        forecaster.updateCity(cityId: cityId)
    }
    
    func seeForecastForCurrentCity() {
        forecaster.seeForecastForCity()
    }
    
    private func buildWeatherDataOptions() -> WeatherDataBuilder.Options {
        .init(
            textOptions: .init(
                isWeatherConditionAsTextEnabled: configManager.isWeatherConditionAsTextEnabled,
                temperatureOptions: .init(
                    unit: TemperatureUnit(rawValue: configManager.temperatureUnit) ?? .fahrenheit,
                    isRoundingOff: configManager.isRoundingOffData
                ),
                isShowingHumidity: configManager.isShowingHumidity
            )
        )
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
                let weatherData = try await weatherRepository.getWeatherViaLatLong(
                    latLong,
                    options: buildWeatherDataOptions()
                )
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
        weatherRepository.getWeatherViaLatLong(
            latLong,
            options: buildWeatherDataOptions(),
            completion: { [weak self] result in
                self?.parseWeatherViaLatLong(result: result)
            }
        )
    }
    
    @available(macOS 12.0, *)
    private func getWeatherWithZipCode(_ zipCode: String) {
        Task {
            do {
                let weatherData = try await weatherRepository.getWeatherViaZipCode(
                    zipCode,
                    options: buildWeatherDataOptions()
                )
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
        weatherRepository.getWeatherForZipCode(
            zipCode,
            options: buildWeatherDataOptions(),
            completion: { [weak self] result in
                guard let `self` = self else { return }

                switch result {
                case let .success(weatherData):
                    self.delegate?.didUpdateWeatherData(weatherData)
                case let .failure(error):
                    guard let weatherError = error as? WeatherError else { return }

                    let errorString = weatherError == WeatherError.zipCodeEmpty ?
                    self.errorStrings.zipCodeErrorString :
                    self.errorStrings.networkErrorString
                    
                    self.delegate?.didFailToUpdateWeatherData(errorString)
                }
            }
        )
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
                let weatherData = try await weatherRepository.getWeatherViaLocation(
                    location,
                    options: buildWeatherDataOptions()
                )
                delegate?.didUpdateWeatherData(weatherData)
            } catch {
                delegate?.didFailToUpdateWeatherData(errorStrings.networkErrorString)
            }
        }
    }
    
    private func getWeatherWithLocationLegacy(_ location: CLLocationCoordinate2D) {
        weatherRepository.getWeatherViaLocation(
            location,
            options: buildWeatherDataOptions(),
            completion: { [weak self] result in
                self?.parseWeatherViaLocation(result: result)
            })
    }
    
    private func parseWeatherViaLatLong(result: Result<WeatherData, Error>) {
        switch result {
        case let .success(weatherData):
            delegate?.didUpdateWeatherData(weatherData)
        case let .failure(error):
            guard let weatherError = error as? WeatherError else { return }

            let isLatLongError = weatherError == WeatherError.latLongEmpty ||
            weatherError == WeatherError.latLongIncorrect
            let errorString = isLatLongError ?
            errorStrings.latLongErrorString :
            errorStrings.networkErrorString
            
            delegate?.didFailToUpdateWeatherData(errorString)
        }
    }
    
    private func parseWeatherViaLocation(result: Result<WeatherData, Error>) {
        switch result {
        case let .success(weatherData):
            delegate?.didUpdateWeatherData(weatherData)
        case .failure:
            delegate?.didFailToUpdateWeatherData(errorStrings.networkErrorString)
        }
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
