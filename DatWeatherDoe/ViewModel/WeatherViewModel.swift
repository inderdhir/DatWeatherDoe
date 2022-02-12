//
//  WeatherViewModel.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation
import Foundation

final class WeatherViewModel: WeatherViewModelType {
    
    weak var delegate: WeatherViewModelDelegate?
    private let configManager: ConfigManagerType
    private let errorLabels = ErrorLabels()
    private let weatherTimerSerialQueue = DispatchQueue(label: "Weather Timer Serial Queue")
    private let forecaster = WeatherForecaster()
    private let logger: DatWeatherDoeLoggerType
    private var weatherRepository: WeatherRepository!
    private var weatherTimer: Timer?
    private var weatherResultParser: WeatherResultParser?
    private lazy var locationFetcher: SystemLocationFetcher = {
        let locationFetcher = SystemLocationFetcher(logger: logger)
        locationFetcher.delegate = self
        return locationFetcher
    }()
    
    init(appId: String, configManager: ConfigManagerType, logger: DatWeatherDoeLoggerType) {
        self.configManager = configManager
        self.logger = logger
        self.weatherRepository = WeatherRepository(appId: appId, logger: logger)
    }
    
    func getUpdatedWeather() {
        weatherTimerSerialQueue.sync {
            weatherTimer?.invalidate()
            weatherTimer = Timer.scheduledTimer(
                withTimeInterval: configManager.refreshInterval,
                repeats: true,
                block: { [weak self] _ in self?.getWeatherWithSelectedSource() })
            weatherTimer?.fire()
        }
    }
    
    func updateCityWith(cityId: Int) {
        forecaster.updateCityWith(cityId: cityId)
    }
    
    func seeForecastForCurrentCity() {
        forecaster.seeForecastForCity()
    }
    
    private func getWeatherWithSelectedSource() {
        let weatherSource = WeatherSource(rawValue: configManager.weatherSource)!
        switch weatherSource {
        case .location:
            getWeatherAfterUpdatingLocation()
        case .zipCode:
            getWeatherViaZipCode()
        case .latLong:
            getWeatherViaLocationCoordinates()
        }
    }
    
    private func getWeatherAfterUpdatingLocation() {
        locationFetcher.startUpdatingLocation()
    }
    
    private func getWeatherViaZipCode() {
        guard let zipCode = configManager.weatherSourceText else {
            delegate?.didFailToUpdateWeatherData(errorLabels.zipCodeErrorString)
            return
        }
        
        weatherRepository.getWeatherViaZipCode(
            zipCode,
            options: buildWeatherDataOptions(),
            completion: { [weak self] result in
                guard let `self` = self else { return }
                
                ZipCodeWeatherResultParser(
                    weatherDataResult: result,
                    delegate: self.delegate,
                    errorLabels: self.errorLabels
                ).parse()
            }
        )
    }
    
    private func getWeatherViaLocationCoordinates() {
        guard let latLong = configManager.weatherSourceText else {
            delegate?.didFailToUpdateWeatherData(errorLabels.latLongErrorString)
            return
        }
        
        weatherRepository.getWeatherViaLatLong(
            latLong,
            options: buildWeatherDataOptions(),
            completion: { [weak self] result in
                guard let `self` = self else { return }
                
                self.weatherResultParser = LocationCoordinatesWeatherResultParser(
                    weatherDataResult: result,
                    delegate: self.delegate,
                    errorLabels: self.errorLabels
                )
                self.weatherResultParser?.parse()
            }
        )
    }
    
    private func buildWeatherDataOptions() -> WeatherDataBuilder.Options {
        .init(textOptions: buildWeatherTextOptions())
    }
    
    private func buildWeatherTextOptions() -> WeatherTextBuilder.Options {
        .init(
            isWeatherConditionAsTextEnabled: configManager.isWeatherConditionAsTextEnabled,
            temperatureOptions: .init(
                unit: TemperatureUnit(rawValue: configManager.temperatureUnit) ?? .fahrenheit,
                isRoundingOff: configManager.isRoundingOffData
            ),
            isShowingHumidity: configManager.isShowingHumidity
        )
    }
    
    private func getWeatherViaLocation(_ location: CLLocationCoordinate2D) {
        weatherRepository.getWeatherViaLocation(
            location,
            options: buildWeatherDataOptions(),
            completion: { [weak self] result in
                guard let `self` = self else { return }

                self.weatherResultParser = SystemLocationWeatherResultParser(
                    weatherDataResult: result,
                    delegate: self.delegate,
                    errorLabels: self.errorLabels
                )
                self.weatherResultParser?.parse()
            })
    }
}

// MARK: SystemLocationFetcherDelegate

extension WeatherViewModel: SystemLocationFetcherDelegate {
    func didUpdateLocation(_ location: CLLocationCoordinate2D, isCachedLocation: Bool) {
        getWeatherViaLocation(location)
    }
    
    func didFailLocationUpdate() {
        delegate?.didFailToUpdateWeatherData(errorLabels.locationErrorString)
    }
}
