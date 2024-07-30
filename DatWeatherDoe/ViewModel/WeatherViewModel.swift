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

@MainActor
final class WeatherViewModel: WeatherViewModelType, ObservableObject {
    private let locationFetcher: SystemLocationFetcherType
    private var weatherFactory: WeatherRepositoryFactoryType
    private let configManager: ConfigManagerType
    private var dataFormatter: WeatherDataFormatterType!
    private let logger: Logger
    private var reachability: NetworkReachability!

    private let forecaster = WeatherForecaster()
    private var weatherTask: Task<Void, Never>?
    private var weatherTimer: Timer?
    private var weatherTimerTask: Task<Void, Never>?
    private var cancellables: Set<AnyCancellable> = []

    @Published var menuOptionData: MenuOptionData?
    @Published var weatherResult: Result<WeatherData, Error>?

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

        setupLocationFetching()
        setupReachability()
    }

    deinit {
        Task { [weatherTask] in
            weatherTask?.cancel()
        }
    }

    func setup(with formatter: WeatherDataFormatter) {
        dataFormatter = formatter
    }

    func getUpdatedWeatherAfterRefresh() {
        weatherTimerTask?.cancel()
        weatherTimerTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                self.getWeatherWithSelectedSource()
                try? await Task.sleep(for: .seconds(configManager.refreshInterval))
            }
        }
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
                        unit: configManager.parsedMeasurementUnit
                    )
                case let .failure(error):
                    updateWeatherData(error)
                }
            })
            .store(in: &cancellables)
    }

    private func setupReachability() {
        reachability = NetworkReachability(
            logger: logger,
            onBecomingReachable: { [weak self] in
                self?.getUpdatedWeatherAfterRefresh()
            }
        )
    }

    private func getWeatherWithSelectedSource() {
        let weatherSource = WeatherSource(rawValue: configManager.weatherSource) ?? .location
        switch weatherSource {
        case .location:
            getWeatherAfterUpdatingLocation()
        case .latLong:
            getWeatherViaLocationCoordinates()
        }
    }

    private func getWeatherAfterUpdatingLocation() {
        locationFetcher.startUpdatingLocation()
    }

    private func getWeatherViaLocationCoordinates() {
        let latLong = configManager.weatherSourceText
        guard !latLong.isEmpty else {
            weatherResult = .failure(WeatherError.latLongIncorrect)
            return
        }

        getWeather(
            repository: weatherFactory.create(latLong: latLong),
            unit: configManager.parsedMeasurementUnit
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

                updateWeatherData(weatherData)
            } catch {
                updateWeatherData(WeatherError.networkError)
            }
        }
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

    private func updateWeatherData(_ data: WeatherData) {
        menuOptionData = MenuOptionData(
            locationText: dataFormatter.getLocation(for: data),
            weatherText: dataFormatter.getWeatherText(for: data),
            sunriseSunsetText: dataFormatter.getSunriseSunset(for: data),
            tempHumidityWindText: dataFormatter.getWindSpeedItem(for: data),
            uvIndexAndAirQualityText: dataFormatter.getUVIndexAndAirQuality(for: data)
        )
        weatherResult = .success(data)
    }

    private func updateWeatherData(_ error: Error) {
        menuOptionData = nil
        weatherResult = .failure(error)
    }
}
