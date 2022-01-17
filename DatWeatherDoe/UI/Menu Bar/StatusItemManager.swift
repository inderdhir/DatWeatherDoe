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
    
    func updateStatusItemWith(weatherData: WeatherData) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            self.statusItem.title = weatherData.textualRepresentation
            self.statusItem.menu?.item(at: 0)?.title = self.getLocationFrom(weatherData: weatherData)
            self.statusItem.image = self.getImageFrom(weatherData: weatherData)
        }
    }
    
    func updateStatusItemWith(error: String) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            self.statusItem.title = error
            self.statusItem.menu?.item(at: 0)?.title = self.unknownString
            self.statusItem.image = nil
        }
    }
    
    private func getLocationFrom(weatherData: WeatherData) -> String {
        weatherData.location ?? unknownString
    }
    
    private func getImageFrom(weatherData: WeatherData) -> NSImage? {
        let image = WeatherConditionImageMapper().map(weatherData.weatherCondition)
        image?.isTemplate = true
        return image
    }
}
