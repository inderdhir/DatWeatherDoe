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
    
    /* Some of these selectors don't work from within this class and
     need to live in AppDelegate
     */
    struct Options {
        let seeFullWeatherSelector: Selector
        let refreshSelector: Selector
        let refreshCallback: () -> Void
        let configureSelector: Selector
        let quitSelector: Selector
    }
    
    private let statusBarManager: StatusBarManager
    private var menuBuilder: MenuBuilder!
    private let popOverManager: PopoverManager
    
    init(
        options: MenuBarManager.Options,
        configManager: ConfigManagerType
    ) {
        menuBuilder = MenuBuilder(
            options: .init(
                seeFullWeatherSelector: options.seeFullWeatherSelector,
                refreshSelector: options.refreshSelector,
                configureSelector: options.configureSelector,
                quitSelector: options.quitSelector
            )
        )
        
        statusBarManager = StatusBarManager(
            menu: menuBuilder.build(),
            configureSelector: options.configureSelector
        )
        popOverManager = PopoverManager(
            statusBarButton: statusBarManager.button,
            configManager: configManager,
            refreshCallback: { options.refreshCallback() }
        )
    }
    
    func updateMenuBarWithWeather(data: WeatherData) {
        DispatchQueue.main.async { [weak self] in
            self?.updateStatusItemWithData(data)
        }
    }
    
    func updateMenuBarWithError(_ error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.updateStatusItemWithError(error)
        }
    }
    
    func configure(_ sender: AnyObject) {
        popOverManager.togglePopover(sender)
    }
    
    private func createMenu(
        seeFullWeatherSelector: Selector,
        refreshSelector: Selector,
        configureSelector: Selector,
        quitSelector: Selector
    ) -> MenuBuilder {
        MenuBuilder(
            options: .init(
                seeFullWeatherSelector: seeFullWeatherSelector,
                refreshSelector: refreshSelector,
                configureSelector: configureSelector,
                quitSelector: quitSelector
            )
        )
    }
    
    private func updateStatusItemWithData(_ data: WeatherData) {
        statusBarManager.updateStatusItemWithData(data)
    }
    
    private func updateStatusItemWithError(_ error: String) {
        statusBarManager.updateStatusItemWithError(error)
    }
}
