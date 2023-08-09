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
    
    private let weatherTimerSerialQueue = DispatchQueue(label: "Weather Timer Serial Queue")
    private let forecaster = WeatherForecaster()
    private let logger: Logger
    private var weatherTimer: Timer?
    private let appId: String
    private let locationFetcher: SystemLocationFetcherType
    private let configManager: ConfigManagerType
    private var weatherFactory: WeatherRepositoryFactoryType.Type
    private var weatherTask: Task<Void, Never>?
    
    private let weatherSubject = PassthroughSubject<Result<WeatherData, Error>, Never>()
    private var cancellables: Set<AnyCancellable> = []
    let weatherResult: AnyPublisher<Result<WeatherData, Error>, Never>
    
    init(
        appId: String,
        locationFetcher: SystemLocationFetcher,
        weatherFactory: WeatherRepositoryFactoryType.Type,
        configManager: ConfigManagerType,
        logger: Logger
    ) {
        self.appId = appId
        self.locationFetcher = locationFetcher
        self.configManager = configManager
        self.weatherFactory = weatherFactory
        self.logger = logger
        
        weatherResult = weatherSubject.eraseToAnyPublisher()
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
                block: { [weak self] _ in self?.getWeatherWithSelectedSource() })
            weatherTimer?.fire()
        }
    }
    
    func updateCity(with cityId: Int) {
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
        locationFetcher.locationResult
            .sink(receiveValue: { [weak self] result in
                guard let self else { return }
                
                switch result {
                case let .success(location):
                    self.getWeather(
                        repository: weatherFactory.create(
                            options: .init(appId: appId, networkClient: NetworkClient(), logger: logger),
                            location: location
                        ),
                        unit: measurementUnit
                    )
                case let .failure(error):
                    self.weatherSubject.send(.failure(error))
                }
            })
            .store(in: &cancellables)
        locationFetcher.startUpdatingLocation()
    }
    
    private func getWeatherViaLocationCoordinates(unit: MeasurementUnit) {
        guard let latLong = configManager.weatherSourceText else {
            weatherSubject.send(.failure(WeatherError.latLongIncorrect))
            return
        }
        
        getWeather(
            repository: weatherFactory.create(
                options: .init(appId: appId, networkClient: NetworkClient(), logger: logger),
                latLong: latLong
            ),
            unit: measurementUnit
        )
    }
    
    private func getWeatherViaCity(unit: MeasurementUnit) {
        guard let city = configManager.weatherSourceText else {
            weatherSubject.send(.failure(WeatherError.cityIncorrect))
            return
        }
        
        getWeather(
            repository: weatherFactory.create(
                options: .init(appId: appId, networkClient: NetworkClient(), logger: logger),
                city: city
            ),
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
    
    private func getWeather(repository: WeatherRepositoryType, unit: MeasurementUnit) {
        weatherTask?.cancel()
        weatherTask = Task {
            do {
                let response = try await repository.getWeather(unit: unit)
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
