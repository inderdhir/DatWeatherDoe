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
            
            if let textualRepresentation = weatherData.textualRepresentation {
                self.statusItem.button?.title = textualRepresentation
            }
            self.statusItem.menu?.item(at: 0)?.title = self.getLocationFrom(weatherData: weatherData)
            
            if weatherData.showWeatherIcon {
                self.statusItem.button?.image = self.getImageFrom(weatherData: weatherData)
                self.statusItem.button?.imagePosition = .imageLeading
            } else {
                self.statusItem.button?.image = nil
            }
        }
    }
    
    func updateStatusItemWith(error: String) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            self.statusItem.button?.title = error
            self.statusItem.menu?.item(at: 0)?.title = self.unknownString
            self.statusItem.button?.image = nil
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
