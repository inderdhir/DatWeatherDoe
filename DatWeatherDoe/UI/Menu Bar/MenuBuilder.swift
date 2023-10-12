//
//  MenuBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Cocoa

final class MenuBuilder {
    struct Options {
        let seeFullWeatherSelector: Selector
        let refreshSelector: Selector
        let configureSelector: Selector
        let quitSelector: Selector
    }

    private let options: MenuBuilder.Options

    init(options: MenuBuilder.Options) {
        self.options = options
    }

    func build() -> NSMenu {
        let menu = NSMenu()
        (buildNonInteractiveOptions() + buildMainOptions()).forEach { menu.addItem($0) }
        return menu
    }

    private func buildNonInteractiveOptions() -> [NSMenuItem] {
        [
            buildUnknownLocationMenuItem(),
            buildWeatherText(),
            buildSunRiseSunSetText(),
            buildTemperatureHumidityAndWindText(),

            .separator(),

            buildSeeFullWeatherMenuItem(),

            .separator()
        ]
    }

    private func buildMainOptions() -> [NSMenuItem] {
        [
            buildRefreshMenuItem(),
            buildConfigureMenuItem(),
            buildQuitMenuItem()
        ]
    }

    private func buildUnknownLocationMenuItem() -> NSMenuItem { emptyMenuItem() }

    private func buildWeatherText() -> NSMenuItem { emptyMenuItem() }

    private func buildSunRiseSunSetText() -> NSMenuItem { emptyMenuItem() }

    private func buildTemperatureHumidityAndWindText() -> NSMenuItem { emptyMenuItem() }

    private func buildSeeFullWeatherMenuItem() -> NSMenuItem {
        let menuItem = NSMenuItem(
            title: NSLocalizedString("See Full Weather", comment: "See Full Weather"),
            action: options.seeFullWeatherSelector,
            keyEquivalent: "f"
        )
        menuItem.keyEquivalentModifierMask = []
        return menuItem
    }

    private func buildRefreshMenuItem() -> NSMenuItem {
        let menuItem = NSMenuItem(
            title: NSLocalizedString("Refresh", comment: "Refresh weather"),
            action: options.refreshSelector,
            keyEquivalent: "r"
        )
        menuItem.keyEquivalentModifierMask = []
        return menuItem
    }

    private func buildConfigureMenuItem() -> NSMenuItem {
        let menuItem = NSMenuItem(
            title: NSLocalizedString("Configure", comment: "Configure app"),
            action: options.configureSelector,
            keyEquivalent: "c"
        )
        menuItem.keyEquivalentModifierMask = []
        return menuItem
    }

    private func buildQuitMenuItem() -> NSMenuItem {
        let menuItem = NSMenuItem(
            title: NSLocalizedString("Quit", comment: "Quit app"),
            action: options.quitSelector,
            keyEquivalent: "q"
        )
        menuItem.keyEquivalentModifierMask = []
        return menuItem
    }

    private func emptyMenuItem() -> NSMenuItem {
        .init(title: "", action: nil, keyEquivalent: "")
    }
}
