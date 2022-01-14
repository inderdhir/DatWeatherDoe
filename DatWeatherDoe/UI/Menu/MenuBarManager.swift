//
//  MenuBarManager.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Cocoa
import Foundation

final class MenuBarManager {
    
    private let statusItem = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.variableLength
    )
    private let popOverManager: PopoverManager
    private let conditionToImageMapper = WeatherConditionImageMapper()
    private lazy var forecaster = WeatherForecaster()
    private lazy var unknownString = NSLocalizedString("Unknown", comment: "Unknown location")
    
    init(
        refreshSelector: Selector,
        quitSelector: Selector,
        refreshCallback: @escaping () -> Void,
        configManager: ConfigManagerType
    ) {
        popOverManager = PopoverManager(
            statusBarButton: statusItem.button,
            configManager: configManager,
            refreshCallback: { refreshCallback() }
        )

        setupStatusItem(
            refreshSelector: refreshSelector,
            quitSelector: quitSelector
        )
    }

    func updateMenuBarWithWeather(data: WeatherData) {
        DispatchQueue.main.async { [weak self] in
            self?.updateCity(cityId: data.cityId)
            self?.updateStatusItemWithData(data)
        }
    }
    
    func updateMenuBarWithError(_ error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.updateStatusItemWithError(error)
        }
    }
    
    private func setupStatusItem(
        refreshSelector: Selector,
        quitSelector: Selector
    ) {
        statusItem.menu = createMenu(
            refreshSelector: refreshSelector,
            quitSelector: quitSelector
        )
        statusItem.button?.action = #selector(togglePopover)
    }
    
    private func updateCity(cityId: Int) {
        forecaster.updateCity(cityId: cityId)
    }
    
    private func updateStatusItemWithData(_ data: WeatherData) {
        statusItem.title = data.textualRepresentation
        statusItem.menu?.item(at: 0)?.title = getWeatherLocationFromData(data)
        statusItem.image = getWeatherImageFromData(data)
    }
    
    private func updateStatusItemWithError(_ error: String) {
        statusItem.title = error
        statusItem.image = nil
    }
    
    private func createMenu(
        refreshSelector: Selector,
        quitSelector: Selector
    ) -> NSMenu {
        MenuBuilder(
            options: .init(
                seeFullWeatherSelector: #selector(seeFullWeather),
                refreshSelector: refreshSelector,
                configureSelector: #selector(togglePopover),
                quitSelector: quitSelector
            )
        ).build()
    }
    
    @objc private func togglePopover(_ sender: AnyObject) {
        popOverManager.togglePopover(sender)
    }
    
    @objc private func seeFullWeather() {
        forecaster.seeForecastForCity()
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
