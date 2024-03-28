//
//  WeatherViewModel.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Combine
import CoreLocation
import Foundation
import OSLog

final class WeatherViewModel: WeatherViewModelType {
    private let locationFetcher: SystemLocationFetcherType
    private var weatherFactory: WeatherRepositoryFactoryType
    private let configManager: ConfigManagerType
    private let logger: Logger

    private let weatherTimerSerialQueue = DispatchQueue(label: "Weather Timer Serial Queue")
    private let forecaster = WeatherForecaster()
    private var weatherTask: Task<Void, Never>?
    private var weatherTimer: Timer?
    private let weatherSubject = PassthroughSubject<Result<WeatherData, Error>, Never>()
    private var cancellables: Set<AnyCancellable> = []
    let weatherResult: AnyPublisher<Result<WeatherData, Error>, Never>

    init(
        locationFetcher: SystemLocationFetcher,
        weatherFactory: WeatherRepositoryFactoryType,
        configManager: ConfigManagerType,
        logger: Logger
    ) {
        self.locationFetcher = locationFetcher
        self.configManager = configManager
        self.weatherFactory = weatherFactory
        self.logger = logger

        weatherResult = weatherSubject.eraseToAnyPublisher()
        
        setupLocationFetching()
    }

    deinit {
        weatherTimer?.invalidate()
        weatherTask?.cancel()
    }

    func startRefreshingWeather() {
        weatherTimerSerialQueue.sync {
            weatherTimer?.invalidate()
            weatherTimer = Timer.scheduledTimer(
                withTimeInterval: configManager.refreshInterval,
                repeats: true,
                block: { [weak self] _ in self?.getWeatherWithSelectedSource() }
            )
            weatherTimer?.fire()
        }
    }

    func updateCity(with cityId: Int) {
        forecaster.updateCityWith(cityId: cityId)
    }

    func seeForecastForCurrentCity() {
        forecaster.seeForecastForCity()
    }
    
    private func setupLocationFetching() {
        locationFetcher.locationResult
            .sink(receiveValue: { [weak self] result in
                guard let self else { return }

                switch result {
                case let .success(location):
                    self.getWeather(
                        repository: weatherFactory.create(location: location),
                        unit: measurementUnit
                    )
                case let .failure(error):
                    self.weatherSubject.send(.failure(error))
                }
            })
            .store(in: &cancellables)
    }

    private func getWeatherWithSelectedSource() {
        let weatherSource = WeatherSource(rawValue: configManager.weatherSource) ?? .location

        switch weatherSource {
        case .location:
            getWeatherAfterUpdatingLocation()
        case .latLong:
            getWeatherViaLocationCoordinates()
        case .zipCode:
            getWeatherViaZipCode()
        case .city:
            getWeatherViaCity()
        }
    }

    private func getWeatherAfterUpdatingLocation() {
        locationFetcher.startUpdatingLocation()
    }

    private func getWeatherViaZipCode() {
        guard let zipCode = configManager.weatherSourceText else {
            weatherSubject.send(.failure(WeatherError.zipCodeIncorrect))
            return
        }

        getWeather(
            repository: weatherFactory.create(zipCode: zipCode),
            unit: measurementUnit
        )
    }

    private func getWeatherViaLocationCoordinates() {
        guard let latLong = configManager.weatherSourceText else {
            weatherSubject.send(.failure(WeatherError.latLongIncorrect))
            return
        }

        getWeather(
            repository: weatherFactory.create(latLong: latLong),
            unit: measurementUnit
        )
    }

    private func getWeatherViaCity() {
        guard let city = configManager.weatherSourceText else {
            weatherSubject.send(.failure(WeatherError.cityIncorrect))
            return
        }

        getWeather(
            repository: weatherFactory.create(city: city),
            unit: measurementUnit
        )
    }

    private func buildWeatherDataOptions(for unit: MeasurementUnit) -> WeatherDataBuilder.Options {
        .init(
            unit: unit,
            showWeatherIcon: configManager.isShowingWeatherIcon,
            textOptions: buildWeatherTextOptions(for: unit)
        )
    }

    private func buildWeatherTextOptions(for unit: MeasurementUnit) -> WeatherTextBuilder.Options {
        let conditionPosition = WeatherConditionPosition(rawValue: configManager.weatherConditionPosition) 
        ?? .beforeTemperature
        return .init(
            isWeatherConditionAsTextEnabled: configManager.isWeatherConditionAsTextEnabled,
            conditionPosition: conditionPosition,
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

    private func getWeather(repository: WeatherRepositoryType, unit: MeasurementUnit) {
        weatherTask = Task {
            do {
                let response = try await repository.getWeather()
                let weatherData = buildWeatherDataWith(
                    response: response,
                    options: buildWeatherDataOptions(for: unit)
                )
                weatherSubject.send(.success(weatherData))
            } catch {
                weatherSubject.send(.failure(error))
            }
        }
    }

    private var measurementUnit: MeasurementUnit {
        MeasurementUnit(rawValue: configManager.measurementUnit) ?? .imperial
    }

    private func buildWeatherDataWith(
        response: WeatherAPIResponse,
        options: WeatherDataBuilder.Options
    ) -> WeatherData {
        WeatherDataBuilder(
            response: response,
            options: options,
            logger: logger
        ).build()
    }
}
