//
//  AppDelegate.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/19/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa
import Combine
import Foundation
import OSLog

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private let configManager: ConfigManagerType = ConfigManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "bundleID", category: "main")
    private var viewModel: WeatherViewModelType!
    private var reachability: NetworkReachability!
    private var menuBarManager: MenuBarManager!
    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_: Notification) {
        setupMenuBar()
        setupWeatherFetching()
        getUpdatedWeather()
    }

    private func setupMenuBar() {
        menuBarManager = MenuBarManager(options: buildMenuBarOptions(), configManager: configManager)
    }

    private func setupWeatherFetching() {
        setupViewModel()
        setupReachability()
    }

    @objc private func getUpdatedWeather() {
        viewModel.startRefreshingWeather()
    }

    private func buildMenuBarOptions() -> MenuBarManager.Options {
        .init(
            seeFullWeatherSelector: #selector(seeFullWeather),
            refreshSelector: #selector(getUpdatedWeather),
            refreshCallback: { [weak self] in self?.getUpdatedWeather() },
            configureSelector: #selector(configure),
            quitSelector: #selector(terminate)
        )
    }

    private func setupViewModel() {
        viewModel = WeatherViewModel(
            locationFetcher: SystemLocationFetcher(logger: logger),
            weatherFactory: WeatherRepositoryFactory(
                appId: WeatherAppIDParser().parse(),
                networkClient: NetworkClient(),
                logger: logger
            ),
            configManager: configManager,
            logger: logger
        )
        viewModel.weatherResult
            .sink(receiveValue: { [weak self] result in
                switch result {
                case let .success(weatherData):
                    self?.updateWeather(with: weatherData)
                case .failure:
                    self?.menuBarManager.updateMenuBarWith(error: "Network Error")
                }
            })
            .store(in: &cancellables)
    }

    private func setupReachability() {
        reachability = NetworkReachability(
            logger: logger,
            onBecomingReachable: { [weak self] in self?.getUpdatedWeather() }
        )
    }

    @objc private func seeFullWeather() {
        viewModel.seeForecastForCurrentCity()
    }

    @objc private func configure(_ sender: AnyObject) {
        menuBarManager.configure(sender)
    }

    @objc private func terminate() { NSApp.terminate(self) }

    private func updateWeather(with weatherData: WeatherData) {
        viewModel.updateCity(with: weatherData.response.cityId)

        let measurementUnit = MeasurementUnit(rawValue: configManager.measurementUnit) ?? .imperial
        menuBarManager.updateMenuBarWith(
            weatherData: weatherData,
            options: .init(
                unit: measurementUnit,
                isRoundingOff: configManager.isRoundingOffData,
                isUnitLetterOff: configManager.isUnitLetterOff,
                isUnitSymbolOff: configManager.isUnitSymbolOff,
                valueSeparator: configManager.valueSeparator
            )
        )
    }
}
