//
//  WeatherViewModel.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation
import Foundation
import OSLog

final class WeatherViewModel: WeatherViewModelType {

    weak var delegate: WeatherViewModelDelegate?

    private let configManager: ConfigManagerType
    private let errorLabels = ErrorLabels()
    private let weatherTimerSerialQueue = DispatchQueue(label: "Weather Timer Serial Queue")
    private let forecaster = WeatherForecaster()
    private let logger: Logger
    private var weatherRepository: WeatherRepository!
    private var weatherTimer: Timer?
    private lazy var locationFetcher: SystemLocationFetcher = {
        let locationFetcher = SystemLocationFetcher(logger: logger)
        locationFetcher.delegate = self
        return locationFetcher
    }()
    private var weatherTask: Task<Void, Never>?

    init(appId: String, configManager: ConfigManagerType, logger: Logger) {
        self.configManager = configManager
        self.logger = logger
        weatherRepository = WeatherRepository(appId: appId, logger: logger)
    }
    
    deinit {
        weatherTimer?.invalidate()
        weatherTask?.cancel()
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
            getWeatherViaLocationCoordinates(unit: measurementUnit)
        case .city:
            getWeatherViaCity(unit: measurementUnit)
        }
    }

    private func getWeatherAfterUpdatingLocation() {
        locationFetcher.startUpdatingLocation()
    }

    private func getWeatherViaLocationCoordinates(unit: MeasurementUnit) {
        guard let latLong = configManager.weatherSourceText else {
            delegate?.didFailToUpdateWeatherData(errorLabels.latLongErrorString)
            return
        }

        weatherTask?.cancel()
        weatherTask = Task {
            do {
                let weatherData = try await weatherRepository.getWeatherViaLatLong(
                    latLong,
                    options: buildWeatherDataOptions(for: unit)
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
    
    private func getWeatherViaCity(unit: MeasurementUnit) {
        guard let city = configManager.weatherSourceText else {
            delegate?.didFailToUpdateWeatherData(errorLabels.cityErrorString)
            return
        }
        
        weatherTask?.cancel()
        weatherTask = Task {
            do {
                let weatherData = try await weatherRepository.getWeatherViaCity(
                    city,
                    options: buildWeatherDataOptions(for: unit)
                )
                delegate?.didUpdateWeatherData(weatherData)
            } catch {
                guard let weatherError = error as? WeatherError else { return }

                let isCityError = weatherError == WeatherError.cityIncorrect
                let errorString = isCityError ?
                errorLabels.cityErrorString : errorLabels.networkErrorString

                delegate?.didFailToUpdateWeatherData(errorString)
            }
        }
    }

    private func buildWeatherDataOptions(for unit: MeasurementUnit) -> WeatherDataBuilder.Options {
        .init(
            unit: unit,
            showWeatherIcon: configManager.isShowingWeatherIcon,
            textOptions: buildWeatherTextOptions(for: unit)
        )
    }

    private func buildWeatherTextOptions(for unit: MeasurementUnit) -> WeatherTextBuilder.Options {
        .init(
            isWeatherConditionAsTextEnabled: configManager.isWeatherConditionAsTextEnabled,
            valueSeparator: configManager.valueSeparator,
            temperatureOptions: .init(
                unit: unit.temperatureUnit,
                isRoundingOff: configManager.isRoundingOffData,
                isUnitLetterOff: configManager.isUnitLetterOff,
                isUnitSymbolOff: configManager.isUnitSymbolOff
            ),
            isShowingHumidity: configManager.isShowingHumidity
        )
    }

    private func getWeatherViaLocation(_ location: CLLocationCoordinate2D, unit: MeasurementUnit) {
        weatherTask?.cancel()
        weatherTask = Task {
            do {
                let weatherData = try await weatherRepository.getWeatherViaLocation(
                    location,
                    options: buildWeatherDataOptions(for: unit)
                )
                delegate?.didUpdateWeatherData(weatherData)
            } catch {
                delegate?.didFailToUpdateWeatherData(errorLabels.networkErrorString)
            }
        }
    }

    private var measurementUnit: MeasurementUnit {
        MeasurementUnit(rawValue: configManager.measurementUnit) ?? .imperial
    }
}

// MARK: SystemLocationFetcherDelegate

extension WeatherViewModel: SystemLocationFetcherDelegate {
    func didUpdateLocation(_ location: CLLocationCoordinate2D, isCachedLocation: Bool) {
        getWeatherViaLocation(location, unit: measurementUnit)
    }

    func didFailLocationUpdate() {
        delegate?.didFailToUpdateWeatherData(errorLabels.locationErrorString)
    }
}
