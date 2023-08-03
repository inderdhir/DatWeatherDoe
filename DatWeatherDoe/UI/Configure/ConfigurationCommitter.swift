//
//  ConfigurationCommitter.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/17/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

final class ConfigurationCommitter {
    
    private let configManager: ConfigManagerType
    
    init(configManager: ConfigManagerType) {
        self.configManager = configManager
    }
    
    func setWeatherSource(_ source: WeatherSource, sourceText: String) {
        configManager.weatherSource = source.rawValue
        configManager.weatherSourceText = source == .location ? nil : sourceText
    }
    
    func setConfigOptions(_ options: ConfigOptions) {
        configManager.setConfigOptions(options)
    }
}
