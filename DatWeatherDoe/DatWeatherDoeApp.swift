//
//  DatWeatherDoeApp.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 6/17/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import MenuBarExtraAccess
import OSLog
import SwiftUI

@main
struct DatWeatherDoeApp: App {
    @State private var configManager: ConfigManager
    @ObservedObject private var configureViewModel = ConfigureViewModel(configManager: ConfigManager())
    @ObservedObject private var viewModel: WeatherViewModel
    @State private var isMenuPresented = false
    @State private var statusItem: NSStatusItem?

    init() {
        configManager = ConfigManager()

        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "bundleID", category: "main")
        viewModel = WeatherViewModel(
            locationFetcher: SystemLocationFetcher(logger: logger),
            weatherFactory: WeatherRepositoryFactory(
                appId: APIKeyParser().parse(),
                networkClient: NetworkClient(),
                logger: logger
            ),
            configManager: ConfigManager(),
            logger: logger
        )
        viewModel.setup(with: WeatherDataFormatter(configManager: configManager))
    }

    var body: some Scene {
        MenuBarExtra(
            content: {
                MenuView(
                    viewModel: viewModel,
                    configureViewModel: configureViewModel,
                    onSeeWeather: {
                        viewModel.seeForecastForCurrentCity()
                        closePopover()
                    },
                    onRefresh: {
                        viewModel.getUpdatedWeatherAfterRefresh()
                        closePopover()
                    },
                    onSave: {
                        closePopover()
                    }
                )
            },
            label: {
                StatusBarView(weatherResult: viewModel.weatherResult)
                    .onAppear {
                        viewModel.getUpdatedWeatherAfterRefresh()
                    }
            }
        )
        .menuBarExtraAccess(isPresented: $isMenuPresented) { statusItem in
            Task { @MainActor in
                self.statusItem = statusItem
            }
        }
        .onChange(of: isMenuPresented) { newValue in
            if !newValue {                
                configureViewModel.saveConfig()
                viewModel.getUpdatedWeatherAfterRefresh()
            }
        }
        .windowStyle(.hiddenTitleBar)
        .menuBarExtraStyle(.window)
    }

    private func closePopover() {
        statusItem?.togglePresented()
    }
}
