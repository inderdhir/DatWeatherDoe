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

    private var statusItemManager: StatusItemManager!
    private var popOverManager: PopoverManager!

    init(
        options: MenuBarManager.Options,
        configManager: ConfigManagerType
    ) {
        statusItemManager = StatusItemManager(
            menu: buildMenuWith(options: options),
            configureSelector: options.configureSelector
        )
        popOverManager = PopoverManager(
            statusBarButton: statusItemManager.button,
            configManager: configManager,
            refreshCallback: { options.refreshCallback() }
        )
    }

    func updateMenuBarWith(weatherData: WeatherData, options: StatusItemManager.Options) {
        statusItemManager.updateStatusItemWith(
            weatherData: weatherData,
            options: options
        )
    }

    func updateMenuBarWith(error: String) {
        statusItemManager.updateStatusItemWith(error: error)
    }

    func configure(_ sender: AnyObject) {
        popOverManager.togglePopover(sender, shouldRefresh: false)
    }

    private func buildMenuWith(options: MenuBarManager.Options) -> NSMenu {
        MenuBuilder(options: buildMenuBuilderOptionsWith(options: options)).build()
    }

    private func buildMenuBuilderOptionsWith(
        options: MenuBarManager.Options
    ) -> MenuBuilder.Options {
        .init(
            seeFullWeatherSelector: options.seeFullWeatherSelector,
            refreshSelector: options.refreshSelector,
            configureSelector: options.configureSelector,
            quitSelector: options.quitSelector
        )
    }
}
