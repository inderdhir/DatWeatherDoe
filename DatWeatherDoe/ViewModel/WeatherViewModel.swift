//
//  WeatherViewModel.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/9/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

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
    private var weatherTimerTask: Task<Void, Never>?

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

        setupReachability()
    }

    deinit {
        Task { [weatherTimerTask] in
            weatherTimerTask?.cancel()
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
                await self.getWeatherWithSelectedSource()
                try? await Task.sleep(for: .seconds(configManager.refreshInterval))
            }
        }
    }

    func seeForecastForCurrentCity() {
        forecaster.seeForecastForCity()
    }

    private func setupReachability() {
        reachability = NetworkReachability(
            logger: logger,
            onBecomingReachable: { [weak self] in
                self?.getUpdatedWeatherAfterRefresh()
            }
        )
    }

    private func getWeatherWithSelectedSource() async {
        let weatherSource = WeatherSource(rawValue: configManager.weatherSource) ?? .location

        do {
            let weatherData = switch weatherSource {
            case .location:
                try await getWeatherAfterUpdatingLocation()
            case .latLong:
                try await getWeatherViaLocationCoordinates()
            }
            updateWeatherData(weatherData)
        } catch {
            updateWeatherData(error)
        }
    }

    private func getWeatherAfterUpdatingLocation() async throws -> WeatherData {
        let locationFetcher = locationFetcher
        let locationTask = Task {
            let location = try await locationFetcher.getLocation()
            return location
        }

        let location = try await locationTask.value
        return try await getWeather(
            repository: weatherFactory.create(location: location),
            unit: configManager.parsedMeasurementUnit
        )
    }

    private func getWeatherViaLocationCoordinates() async throws -> WeatherData {
        let latLong = configManager.weatherSourceText
        guard !latLong.isEmpty else {
            throw WeatherError.latLongIncorrect
        }

        return try await getWeather(
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
            isShowingHumidity: configManager.isShowingHumidity,
            isShowingUVIndex: configManager.isShowingUVIndex
        )
    }

    private func getWeather(
        repository: WeatherRepositoryType,
        unit: MeasurementUnit
    ) async throws -> WeatherData {
        let repository = repository

        let responseTask = Task {
            let response = try await repository.getWeather()
            return response
        }

        do {
            let response = try await responseTask.value
            let weatherData = WeatherDataBuilder(
                response: response,
                options: buildWeatherDataOptions(for: unit),
                logger: logger
            ).build()
            return weatherData
        } catch {
            throw WeatherError.networkError
        }
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
