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

        // Category icons in dropdown menu
        locationMenuItem?.image = WeatherConditionImageMapper().map(.location)
        temperatureForecastMenuItem?.image = WeatherConditionImageMapper().map(.thermometer)
        sunRiseSetMenuItem?.image = WeatherConditionImageMapper().map(.sunny)
        windMenuItem?.image = WeatherConditionImageMapper().map(.windy)
        // By making the images "templates", macOS knows to adjust the image color based on
        // the desktop settings (light, dark), so they remain visible either way.
        locationMenuItem?.image?.isTemplate = true
        temperatureForecastMenuItem?.image?.isTemplate = true
        sunRiseSetMenuItem?.image?.isTemplate = true
        windMenuItem?.image?.isTemplate = true
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
            
            self.locationMenuItem?.title = [self.getLocationFrom(weatherData: weatherData),
                                            self.getConditionItemFrom(
                                                weatherData: weatherData)].joined(separator: " - ")
            self.temperatureForecastMenuItem?.title = self.getWeatherTextFrom(
                weatherData: weatherData,
                temperatureOptions: temperatureOptions
            )
            self.sunRiseSetMenuItem?.title = self.getSunRiseSetFrom(
                weatherData: weatherData)
            self.windMenuItem?.title = self.getWindSpeedItemFrom(
                weatherData: weatherData)
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

    private func getSunRiseSetFrom(weatherData: WeatherData) -> String {
        RiseSetTextBuilder(
            sunset: weatherData.sunset,
            sunrise: weatherData.sunrise
        ).build()
    }

    private func getConditionItemFrom(weatherData: WeatherData) -> String {
        return WeatherConditionTextMapper().map(weatherData.weatherCondition)
    }

    private func getWindSpeedItemFrom(weatherData: WeatherData) -> String {
        let windSpeedStr = [String(weatherData.windData.speed), "m/s"].joined()
        let windDegreesStr = [String(weatherData.windData.degrees), TemperatureHelpers.degreeString].joined()
        let windDirectionStr = ["(", weatherData.windData.getDirectionStr(), ")"].joined()
        let windAndDegreesStr = [windSpeedStr, windDegreesStr].joined(separator: " - ")
        let windFullStr = [windAndDegreesStr, windDirectionStr].joined(separator: " ")
        return windFullStr
    }

    private func clearNonInteractiveMenuOptions() {
        locationMenuItem?.title = unknownString
        temperatureForecastMenuItem?.title = unknownString
        sunRiseSetMenuItem?.title = unknownString
        windMenuItem?.title = unknownString
    }
    
    private var locationMenuItem: NSMenuItem? { statusItem.menu?.item(at: 0) }
    private var temperatureForecastMenuItem: NSMenuItem? { statusItem.menu?.item(at: 1) }
    private var sunRiseSetMenuItem: NSMenuItem? { statusItem.menu?.item(at: 2) }
    private var windMenuItem: NSMenuItem? { statusItem.menu?.item(at: 3) }
}
