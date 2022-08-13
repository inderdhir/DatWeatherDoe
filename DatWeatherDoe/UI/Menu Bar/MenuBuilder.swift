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
            buildSunRiseSetText(),
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
    
    private func buildSunRiseSetText() -> NSMenuItem { emptyMenuItem() }

    private func buildTemperatureHumidityAndWindText() -> NSMenuItem { emptyMenuItem() }
    
    private func buildSeeFullWeatherMenuItem() -> NSMenuItem {
        .init(
            title: NSLocalizedString("See Full Weather", comment: "See Full Weather"),
            action: options.seeFullWeatherSelector,
            keyEquivalent: "F"
        )
    }
    
    private func buildRefreshMenuItem() -> NSMenuItem {
        .init(
            title: NSLocalizedString("Refresh", comment: "Refresh weather"),
            action: options.refreshSelector,
            keyEquivalent: "R"
        )
    }
    
    private func buildConfigureMenuItem() -> NSMenuItem {
        .init(
            title: NSLocalizedString("Configure", comment: "Configure app"),
            action: options.configureSelector,
            keyEquivalent: "C"
        )
    }
    
    private func buildQuitMenuItem() -> NSMenuItem {
        .init(
            title: NSLocalizedString("Quit", comment: "Quit app"),
            action: options.quitSelector,
            keyEquivalent: "Q"
        )
    }
    
    private func emptyMenuItem() -> NSMenuItem {
        .init(title: "", action: nil, keyEquivalent: "")
    }
}
