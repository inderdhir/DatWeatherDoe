//
//  AppDelegate.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/19/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa
import Foundation
import OSLog

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    private let configManager: ConfigManagerType = ConfigManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "bundleID", category: "main")
    private var viewModel: WeatherViewModelType!
    private var reachability: NetworkReachability!
    private var menuBarManager: MenuBarManager!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
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
        viewModel.getUpdatedWeather()
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
            appId: WeatherAppIDParser().parse(),
            configManager: configManager,
            logger: logger
        )
        viewModel.delegate = self
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
}

// MARK: WeatherViewModelDelegate

extension AppDelegate: WeatherViewModelDelegate {
    func didUpdateWeatherData(_ data: WeatherData) {
        viewModel.updateCityWith(cityId: data.cityId)

        let measurementUnit = MeasurementUnit(rawValue: configManager.measurementUnit) ?? .imperial
        menuBarManager.updateMenuBarWith(
            weatherData: data,
            options: .init(
                unit: measurementUnit,
                isRoundingOff: configManager.isRoundingOffData,
                isUnitLetterOff: configManager.isUnitLetterOff,
                isUnitSymbolOff: configManager.isUnitSymbolOff
            )
        )
    }
    
    func didFailToUpdateWeatherData(_ error: String) {
        menuBarManager.updateMenuBarWith(error: error)
    }
}
