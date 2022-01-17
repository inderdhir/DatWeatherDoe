//
//  StatusBarManager.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import AppKit

final class StatusBarManager {
    
    var button: NSStatusBarButton? { statusItem.button }
    
    private let statusItem = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength
    )
    private let conditionToImageMapper = WeatherConditionImageMapper()
    private lazy var unknownString = NSLocalizedString("Unknown", comment: "Unknown location")

    init(menu: NSMenu, configureSelector: Selector) {
        statusItem.menu = menu
        statusItem.button?.action = configureSelector
    }
    
    func updateStatusItemWithData(_ data: WeatherData) {
        statusItem.title = data.textualRepresentation
        statusItem.menu?.item(at: 0)?.title = getWeatherLocationFromData(data)
        statusItem.image = getWeatherImageFromData(data)
    }
    
    func updateStatusItemWithError(_ error: String) {
        statusItem.title = error
        statusItem.image = nil
    }
    
    private func getWeatherLocationFromData(_ data: WeatherData) -> String {
        data.location ?? unknownString
    }
    
    private func getWeatherImageFromData(_ data: WeatherData) -> NSImage? {
        let image = conditionToImageMapper.mapConditionToImage(data.weatherCondition)
        image?.isTemplate = true
        return image
    }
}
