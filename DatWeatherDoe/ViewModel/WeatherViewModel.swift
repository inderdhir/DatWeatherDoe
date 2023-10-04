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
    private lazy var locationFetcher: SystemLocationFetcher = {
        let locationFetcher = SystemLocationFetcher(logger: logger)
        locationFetcher.delegate = self
        return locationFetcher
    }()

    init(appId: String, configManager: ConfigManagerType, logger: DatWeatherDoeLoggerType) {
        self.configManager = configManager
        self.logger = logger
        weatherRepository = WeatherRepository(appId: appId, logger: logger)
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
        let weatherSource = WeatherSource(rawValue: configManager.weatherSource) ?? .location
        switch weatherSource {
        case .location:
            getWeatherAfterUpdatingLocation()
        case .latLong:
            getWeatherViaLocationCoordinates()
        case .city:
            getWeatherViaCity()
        }
    }

    private func getWeatherAfterUpdatingLocation() {
        locationFetcher.startUpdatingLocation()
    }

    private func getWeatherViaLocationCoordinates() {
        guard let latLong = configManager.weatherSourceText else {
            delegate?.didFailToUpdateWeatherData(errorLabels.latLongErrorString)
            return
        }
        
        Task {
            do {
                let weatherData = try await weatherRepository.getWeatherViaLatLong(
                    latLong,
                    options: buildWeatherDataOptions()
                )
                delegate?.didUpdateWeatherData(weatherData)
            } catch {
                guard let weatherError = error as? WeatherError else { return }

                let isLatLongError = weatherError == WeatherError.latLongIncorrect
                let errorString = isLatLongError ?
                errorLabels.latLongErrorString : errorLabels.networkErrorString
                
                delegate?.didFailToUpdateWeatherData(errorString)
            }
        }
    }
    
    private func getWeatherViaCity() {
        guard let city = configManager.weatherSourceText else {
            delegate?.didFailToUpdateWeatherData(errorLabels.cityErrorString)
            return
        }
        
        weatherRepository.getWeatherViaCity(
            city,
            options: buildWeatherDataOptions(),
            completion: { [weak self] result in
                guard let `self` = self else { return }

                CityWeatherResultParser(
                    weatherDataResult: result,
                    delegate: self.delegate,
                    errorLabels: self.errorLabels
                ).parse()
            }
        )
    }

    private func buildWeatherDataOptions() -> WeatherDataBuilder.Options {
        .init(
            showWeatherIcon: configManager.isShowingWeatherIcon,
            textOptions: buildWeatherTextOptions()
        )
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
        Task {
            do {
                let weatherData = try await weatherRepository.getWeatherViaLocation(
                    location,
                    options: buildWeatherDataOptions()
                )
                delegate?.didUpdateWeatherData(weatherData)
            } catch {
                delegate?.didFailToUpdateWeatherData(errorLabels.networkErrorString)
            }
        }
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
