//
//  StatusItemManager.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import AppKit

final class StatusItemManager {
    
    var button: NSStatusBarButton? { statusItem.button }
    
    private let statusItem = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength
    )
    private lazy var unknownString = NSLocalizedString("Unknown", comment: "Unknown location")

    init(menu: NSMenu, configureSelector: Selector) {
        statusItem.menu = menu
        statusItem.button?.action = configureSelector
    }
    
    func updateStatusItemWith(
        weatherData: WeatherData,
        temperatureOptions: TemperatureTextBuilder.Options
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            if let textualRepresentation = weatherData.textualRepresentation {
                self.statusItem.button?.title = textualRepresentation
            }
            if weatherData.showWeatherIcon {
                self.statusItem.button?.image = self.getImageFrom(weatherData: weatherData)
                self.statusItem.button?.imagePosition = .imageLeading
            } else {
                self.statusItem.button?.image = nil
            }
            
            self.locationMenuItem?.title = self.getLocationFrom(weatherData: weatherData)
            self.temperatureForecastMenuItem?.title = self.getWeatherTextFrom(
                weatherData: weatherData,
                temperatureOptions: temperatureOptions
            )
            self.conditionMenuItem?.title = self.getConditionHumidityAndWindSpeedItemFrom(weatherData: weatherData)
        }
    }
    
    func updateStatusItemWith(error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.button?.title = error
            self?.statusItem.button?.image = nil

            self?.clearNonInteractiveMenuOptions()
        }
    }
    
    private func getImageFrom(weatherData: WeatherData) -> NSImage? {
        let image = WeatherConditionImageMapper().map(weatherData.weatherCondition)
        image?.isTemplate = true
        return image
    }
    
    private func getLocationFrom(weatherData: WeatherData) -> String {
        weatherData.location ?? unknownString
    }
    
    private func getWeatherTextFrom(
        weatherData: WeatherData,
        temperatureOptions: TemperatureTextBuilder.Options
    ) -> String {
        TemperatureForecastTextBuilder(
            temperatureData: weatherData.temperatureData,
            options: temperatureOptions
        ).build()
    }
    
    private func getConditionHumidityAndWindSpeedItemFrom(weatherData: WeatherData) -> String {
        let windSpeedStr = [String(weatherData.windData.speed), "m/s"].joined()
        let windDegreesStr = [String(weatherData.windData.degrees), TemperatureHelpers.degreeString].joined()
        let windAndDegreesStr = [windSpeedStr, windDegreesStr].joined(separator: " | ")
        let conditionStr = WeatherConditionTextMapper().map(weatherData.weatherCondition)
        return [windAndDegreesStr, conditionStr].joined(separator: " - ")
    }
    
    private func clearNonInteractiveMenuOptions() {
        locationMenuItem?.title = unknownString
        temperatureForecastMenuItem?.title = unknownString
        conditionMenuItem?.title = unknownString
    }
    
    private var locationMenuItem: NSMenuItem? { statusItem.menu?.item(at: 0) }
    private var temperatureForecastMenuItem: NSMenuItem? { statusItem.menu?.item(at: 1) }
    private var conditionMenuItem: NSMenuItem? { statusItem.menu?.item(at: 2) }
}
